module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    has_one :source_file, foreign_key: :active_storage_attachment_id, dependent: :destroy

    after_commit :create_associated_source_file, on: :create
  end

  private

  def create_associated_source_file
    if record_type == "StandardsImport"
      Rails.error.handle do
        unless source_file
          create_source_file!
        end
      end
    end
  end
end
