class FileImport < ApplicationRecord
  belongs_to :active_storage_attachment, class_name: "ActiveStorage::Attachment"

  enum :status, [:pending, :processing, :completed]

  def filename
    active_storage_attachment.blob.filename
  end
end
