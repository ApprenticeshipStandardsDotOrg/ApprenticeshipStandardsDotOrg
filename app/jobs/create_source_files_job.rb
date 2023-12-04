class CreateSourceFilesJob < ApplicationJob
  queue_as :default

  def perform(standards_import)
    standards_import.files.each do |file|
      courtesy_notification = standards_import.courtesy_notification
      Rails.error.handle do
        SourceFile
          .create_with(courtesy_notification: courtesy_notification)
          .find_or_create_by!(active_storage_attachment_id: file.id)
      end
    end
  end
end
