namespace :standards_import do
  task notify_uploaders_of_conversion_completion: :environment do
    if Date.current.tuesday? || ENV["FORCE"] == "true"
      puts "Running manual conversion complete notification job"
      NotifyUploadersOfManualConversionCompletionJob.perform_later
    else
      puts "Not Tuesday, skipping"
      puts "Use FORCE=true to force this task"
    end
  end

  task clean_up_bulletins: :environment do
    StandardsImport.where(bulletin: true).find_each do |standards_import|
      standards_import.clean_up_unprocessed_bulletin!
    end
  end
end
