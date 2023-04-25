class SourceFile < ApplicationRecord
  belongs_to :active_storage_attachment, class_name: "ActiveStorage::Attachment"
  belongs_to :assignee, class_name: "User", optional: true
  has_many :data_imports, -> { includes(:occupation_standard, file_attachment: :blob) }

  enum :status, [:pending, :completed]

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

  private

  def standards_import
    active_storage_attachment.record
  end
end
