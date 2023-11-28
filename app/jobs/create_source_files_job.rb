class CreateSourceFilesJob < ApplicationJob
  queue_as :default

  def perform(standards_import)
    standards_import.files.each do |file|
      Rails.error.handle do
        SourceFile.find_or_create_by!(active_storage_attachment_id: file.id)
      end
    end
  end
end
