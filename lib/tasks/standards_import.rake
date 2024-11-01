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

  task notify_uploaders_of_conversions_for_last_month: :environment do
    def report_date
      date = Date.today.beginning_of_month
      if date.on_weekend?
        date = date.next_occurring(:monday)
      end
      date
    end

    if Date.today == report_date || ENV["FORCE"] == "true"
      puts "Running monthly conversion complete notification job"
      NotifyUploadsOfConversionsForPeriodJob.perform_later(
        date_range: Date.today.last_month.beginning_of_month..Date.today.last_month.end_of_month
      )
    else
      puts "Not the first day of the month (or following Monday), skipping"
      puts "Use FORCE=true to force this task"
    end
  end
end
