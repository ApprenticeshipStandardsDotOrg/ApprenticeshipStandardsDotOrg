class SourceFile < ApplicationRecord
  belongs_to :active_storage_attachment, class_name: "ActiveStorage::Attachment"
  has_many :data_imports, -> { includes(:occupation_standard, file_attachment: :blob) }

  enum :status, [:pending, :completed]

  def filename
    active_storage_attachment.blob.filename
  end

  def url
    active_storage_attachment.blob.url
  end
end
