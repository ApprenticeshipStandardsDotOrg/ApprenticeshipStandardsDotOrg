class FileImport < ApplicationRecord
  belongs_to :active_storage_attachment, class_name: "ActiveStorage::Attachment"

  enum :status, [:pending, :processing, :completed]
end
