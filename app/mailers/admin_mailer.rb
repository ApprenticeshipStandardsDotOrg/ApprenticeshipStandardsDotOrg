class AdminMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.admin_mailer.new_standards_import.subject
  #
  def new_standards_import(standards_import)
    @standards_import = standards_import

    mail to: "patrick@workhands.us",
      subject: "New standards import uploaded"
  end

  def new_contact_request(contact_request)
    @contact_request = contact_request

    mail to: "patrick@workhands.us",
      subject: "New ApprenticeshipStandards Contact Request"
  end

  def daily_uploads_report
    @data_imports = DataImport.recent_uploads

    if @data_imports.any?
      date = Time.zone.yesterday.to_date
      mail to: "info@workhands.us",
        cco: "sarah.lima@thoughtbot.com",
        subject: "Daily imported standards report #{date}"
    end
  end
end
