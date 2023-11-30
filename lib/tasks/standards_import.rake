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
end
