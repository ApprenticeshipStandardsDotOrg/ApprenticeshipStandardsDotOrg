class AdminMailerPreview < ActionMailer::Preview
  def daily_uploads_report
    AdminMailer.daily_uploads_report
  end

  def daily_redacted_files_report
    AdminMailer.daily_redacted_files_report
  end
end
