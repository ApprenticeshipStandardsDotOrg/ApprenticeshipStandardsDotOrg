class AdminMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.admin_mailer.new_standards_import.subject
  #
  helper_method :public_domain

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
        subject: "Daily imported standards report #{date}"
    end
  end

  def daily_redacted_files_report
    @recently_redacted_records = Imports::Pdf.includes(file_attachment: :blob).recently_redacted

    if @recently_redacted_records.any?
      date = Time.zone.yesterday.to_date
      mail to: "info@workhands.us",
        subject: "Daily redacted files report #{date}"
    end
  end

  private

  def public_domain
    value = ENV["PUBLIC_DOMAIN"]
    if value =~ /localhost\:3000\z/
      value = nil
    end

    value || Rails.application.config.action_mailer.default_url_options[:host]
  end
end
