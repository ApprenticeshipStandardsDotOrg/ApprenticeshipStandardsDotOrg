namespace :redacted_files do
  task daily_report: :environment do
    AdminMailer.daily_redacted_files_report.deliver_now
  end
end
