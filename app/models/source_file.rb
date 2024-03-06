class SourceFile < ApplicationRecord
  belongs_to :active_storage_attachment, class_name: "ActiveStorage::Attachment"
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :original_source_file, class_name: "SourceFile", optional: true
  has_many :data_imports, -> { includes(:occupation_standard, file_attachment: :blob) }
  has_many :associated_occupation_standards, -> { distinct }, through: :data_imports, source: :occupation_standard
  has_one_attached :redacted_source_file

  enum :status, [:pending, :completed, :needs_support, :needs_human_review, :archived]
  enum courtesy_notification: [:not_required, :pending, :completed], _prefix: true

  after_create_commit :convert_doc_file_to_pdf

  PDF_CONTENT_TYPE = "application/pdf"

  def self.pdf_attachment
    includes(active_storage_attachment: :blob).where(
      active_storage_attachment: {
        active_storage_blobs: {
          content_type: PDF_CONTENT_TYPE
        }
      }
    )
  end

  def self.docx_attachment
    joins(active_storage_attachment: :blob).where(
      active_storage_attachment: {
        active_storage_blobs: {content_type: DocxFile.content_type}
      }
    )
  end

  def self.recently_redacted(start_time: Time.zone.yesterday.beginning_of_day, end_time: Time.zone.yesterday.end_of_day)
    where(
      redacted_at: (
        start_time..end_time
      )
    )
  end

  def self.not_redacted
    includes(:redacted_source_file_attachment).where(
      redacted_source_file_attachment: {
        id: nil
      }
    )
  end

  def self.already_redacted
    not_redacted.invert_where
  end

  def self.ready_for_redaction
    where(public_document: false).completed.not_redacted.pdf_attachment
  end

  def filename
    active_storage_attachment.blob.filename
  end

  def url
    active_storage_attachment.blob.url
  end

  def needs_courtesy_notification?
    completed? && courtesy_notification_pending?
  end

  # This saves the metadata as JSON instead of string.
  # See https://github.com/codica2/administrate-field-jsonb/issues/1
  def metadata=(value)
    self[:metadata] = value.is_a?(String) ? JSON.parse(value) : value
  end

  def organization
    standards_import.organization
  end

  def notes
    standards_import.notes
  end

  def claimed?
    assignee.present?
  end

  def standards_import
    active_storage_attachment.record
  end

  def pdf?
    active_storage_attachment.blob.content_type == PDF_CONTENT_TYPE
  end

  def docx?
    active_storage_attachment.blob.content_type == DocxFile.content_type
  end

  def redacted_source_file_url
    redacted_source_file&.blob&.url
  end

  def file_for_redaction
    redacted_source_file.attached? ? redacted_source_file : active_storage_attachment
  end

  private

  def convert_doc_file_to_pdf
    if docx?
      DocToPdfConverterJob.perform_later(self)
    end
  end
end
