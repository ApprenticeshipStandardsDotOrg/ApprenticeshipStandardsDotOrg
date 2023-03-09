namespace :after_party do
  desc "Deployment task: :migrate_file_import_to_source_file"
  task migrate_file_import_to_source_file: :environment do
    puts "Running deploy task ':migrate_file_import_to_source_file'"

    # Clean out duplicates from StandardImport records:
    StandardsImport.find_each do |standards_import|
      standards_import.files.each_with_index do |attached_file, index|
        next if index.zero?

        file_import = FileImport.find_by(active_storage_attachment_id: attached_file.id)
        if file_import
          file_import.destroy!
        end

        attached_file.purge
      end
    end

    # Migrate FileImport to SourceFile
    FileImport.find_each do |file_import|
      if file_import.active_storage_attachment
        SourceFile.find_or_create_by!(
          active_storage_attachment_id: file_import.active_storage_attachment_id,
          status: file_import.status,
          metadata: file_import.metadata || {}
        )
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
