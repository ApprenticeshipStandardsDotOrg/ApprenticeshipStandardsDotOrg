
class AdminMailerPreview < ActionMailer::Preview
  def daily_uploads_report
    recent_uploads = DataImport.recent_uploads

    if recent_uploads.empty?
      user = User.first
      FactoryBot.create(:data_import, user: user)
    end
    
    AdminMailer.daily_uploads_report
  end
end
