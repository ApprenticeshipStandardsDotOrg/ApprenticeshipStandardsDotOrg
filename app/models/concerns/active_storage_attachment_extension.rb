module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    has_one :source_file, foreign_key: :active_storage_attachment_id, dependent: :destroy

    after_commit :create_source_file, on: :create
  end

  def has_linked_original_file?
    source_file&.original_source_file.present?
  end

  private

  def create_source_file
    if record_type == "StandardsImport"
      linkable_docx_files =
        SourceFile
        .where(active_storage_attachment_id: record.files.map(&:id))
        .docx_attachment
        .where.not(link_to_pdf_filename: nil)

      Rails.error.handle do
        SourceFile.create!(
          active_storage_attachment: self,
          courtesy_notification: record.courtesy_notification
        ).tap { maybe_link_to_original_source_file(_1, linkable_docx_files) }
      end
    end
  end

  def maybe_link_to_original_source_file(source_file, linkable_docx_files)
    return unless source_file.pdf?
    return if linkable_docx_files.blank?

    filename = source_file.active_storage_attachment.filename.to_s
    original_source_file = linkable_docx_files.find do |other|
      other.link_to_pdf_filename == filename
    end

    if original_source_file.present?
      source_file.update!(original_source_file:)
      original_source_file.update!(
        link_to_pdf_filename: nil,
        status: :archived,
        courtesy_notification: :not_required
      )
    end
  end
end
