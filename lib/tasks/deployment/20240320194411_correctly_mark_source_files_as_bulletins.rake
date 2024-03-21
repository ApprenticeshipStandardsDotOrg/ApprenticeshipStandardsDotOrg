namespace :after_party do
  desc "Deployment task: correctly_mark_source_files_as_bulletins"
  task correctly_mark_source_files_as_bulletins: :environment do
    puts "Running deploy task 'correctly_mark_source_files_as_bulletins'"

    StandardsImport.where(bulletin: true).find_each do |standards_import|
      standards_import.source_files.each do |source_file|
        if source_file.filename.to_s.match?(/bulletin/i)
          if source_file.original_source_file.nil? && source_file.converted_source_file.nil?
            # File started as a pdf OR it was a docx file with embedded
            # attachments, so mark it as the bulletin
            source_file.update!(bulletin: true)
          elsif source_file.converted_source_file.present?
            # This file was originally a doc file that was converted, so mark it
            # as the bulletin
            source_file.update!(bulletin: true)
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
