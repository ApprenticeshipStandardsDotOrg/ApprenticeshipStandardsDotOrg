namespace :after_party do
  desc "Deployment task: mark_scraper_source_files_as_public"
  task mark_scraper_source_files_as_public: :environment do
    puts "Running deploy task 'mark_scraper_source_files_as_public'"

    StandardsImport.where(public_document: true).find_each do |import|
      next unless import.notes.match?(/Scraper/)

      import.source_files.compact.each do |source_file|
        source_file.update!(public_document: true)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
