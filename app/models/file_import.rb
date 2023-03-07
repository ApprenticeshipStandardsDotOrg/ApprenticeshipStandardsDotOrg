class FileImport < ApplicationRecord
  belongs_to :active_storage_attachment, class_name: "ActiveStorage::Attachment"
  has_one :data_import

  enum :status, [:pending, :processing, :completed]

  def filename
    active_storage_attachment.blob.filename
  end

  def url
    active_storage_attachment.blob.url
  end
end
