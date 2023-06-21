class AdminMailerPreview < ActionMailer::Preview
  def daily_uploads_report
    AdminMailer.daily_uploads_report
  end
end
