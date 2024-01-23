namespace :redacted_files do
  task daily_report: :environment do
    AdminMailer.daily_redacted_files_report.deliver_now
  end

  task generate_from_docx: :environment do
    DocToPdfConverter.convert_all
  end
end
