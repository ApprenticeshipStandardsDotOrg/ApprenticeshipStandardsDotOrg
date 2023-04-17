namespace :after_party do
  desc "Deployment task: cleanup_duplicate_source_files"
  task cleanup_duplicate_source_files: :environment do
    puts "Running deploy task 'cleanup_duplicate_source_files'"

    StandardsImport.where("notes LIKE ?", "From Scraper::WashingtonJob%").each do |si|
      si.files.each_with_index do |attachment, index|
        next if index.zero?

        source_file = attachment.source_file
        source_file.destroy!

        attachment.purge
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
