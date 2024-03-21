namespace :after_party do
  desc "Deployment task: convert_remaining_word_files_to_pdf"
  task convert_remaining_word_files_to_pdf: :environment do
    puts "Running deploy task 'convert_remaining_word_files_to_pdf'"

    StandardsImport.find_each do |standard_import|
      standard_import.source_files.each do |source_file|
        DocToPdfConverterJob.perform_later(source_file)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
