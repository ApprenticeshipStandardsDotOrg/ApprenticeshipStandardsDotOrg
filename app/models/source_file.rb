class SourceFile < ApplicationRecord
  belongs_to :active_storage_attachment, class_name: "ActiveStorage::Attachment"
  belongs_to :assignee, class_name: "User", optional: true
  has_many :data_imports, -> { includes(:occupation_standard, file_attachment: :blob) }
  has_many :associated_occupation_standards, through: :data_imports, source: :occupation_standard
  has_one_attached :redacted_source_file

  enum :status, [:pending, :completed, :needs_support]

  def filename
    active_storage_attachment.blob.filename
  end

  def url
    active_storage_attachment.blob.url
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
    active_storage_attachment.blob.content_type == "application/pdf"
  end

  def redacted_source_file_url
    redacted_source_file&.blob&.url
  end

  def file_for_redaction
    redacted_source_file.attached? ? redacted_source_file : active_storage_attachment
  end
end
