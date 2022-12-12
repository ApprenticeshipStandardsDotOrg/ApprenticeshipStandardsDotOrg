module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    has_one :file_import

    after_commit :create_file_import, on: :create
  end

  private

  def create_file_import
    if record_type == "StandardsImport"
      Rails.error.handle do
        FileImport.create!(active_storage_attachment: self)
      end
    end
  end
end
