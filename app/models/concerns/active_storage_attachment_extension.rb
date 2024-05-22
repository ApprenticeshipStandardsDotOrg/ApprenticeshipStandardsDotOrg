module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    has_one :source_file, foreign_key: :active_storage_attachment_id, dependent: :destroy

    after_commit :create_source_file, on: :create
  end

  def has_linked_original_file?
    source_file&.original_source_file.present?
  end

  private

  def create_source_file
    if !Flipper.enabled?(:show_imports_in_administrate) && record_type == "StandardsImport"
      CreateSourceFileJob.perform_later(self)
    end
  end
end
