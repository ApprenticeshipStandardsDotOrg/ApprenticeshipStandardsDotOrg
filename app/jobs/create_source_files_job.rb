class CreateSourceFilesJob < ApplicationJob
  queue_as :default

  def perform(standards_import)
    linkable_docx_files =
      SourceFile
        .where(active_storage_attachment_id: standards_import.files.map(&:id))
        .docx_attachment
        .where.not(link_to_pdf_filename: nil)

    standards_import.files.each do |file|
      courtesy_notification = standards_import.courtesy_notification
      Rails.error.handle do
        SourceFile.transaction do
          source_file = SourceFile
            .create_with(courtesy_notification:)
            .find_or_create_by!(active_storage_attachment_id: file.id)
            .tap { maybe_link_to_original_source_file(_1, linkable_docx_files) }
        end
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
        status: :archived
      )
    end
  end
end
