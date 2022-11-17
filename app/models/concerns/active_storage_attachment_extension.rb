module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    has_one :file_import
  end
end

Rails.configuration.to_prepare do
  ActiveStorage::Attachment.include ActiveStorageAttachmentExtension
end
