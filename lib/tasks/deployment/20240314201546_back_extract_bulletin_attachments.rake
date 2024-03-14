namespace :after_party do
  desc "Deployment task: back_extract_bulletin_attachments"
  task back_extract_bulletin_attachments: :environment do
    puts "Running deploy task 'back_extract_bulletin_attachments'"

    # Checking for bulletin: false since we want to back extract Bulletins
    # that existed before we added that flag.
    if Rails.env.production? && ENV.fetch("APP_ENVIRONMENT", Rails.env) == "production"
      StandardsImport.where(bulletin: false).where("notes LIKE ?", "%BulletinsJob%").find_each do |standards_import|
        standards_import.source_files.each do |source_file|
          if source_file.docx?
            Scraper::ExportFileAttachmentsJob.perform_later(source_file)
          end
        end
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
