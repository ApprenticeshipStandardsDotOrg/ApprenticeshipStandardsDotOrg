namespace :data_import do
  task daily_report: :environment do
    AdminMailer.daily_uploads_report.deliver_now
  end
end
