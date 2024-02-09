module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    has_one :source_file, foreign_key: :active_storage_attachment_id, dependent: :destroy
  end

  def has_linked_original_file?
    source_file.original_source_file.present?
  end
end
