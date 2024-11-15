class GuestMailer < ApplicationMailer
  MAILER_BCC = "info@workhands.us"

  def self.mailer_host
    @mailer_host ||= ENV.fetch(
      "PUBLIC_DOMAIN",
      Rails.application.config.action_mailer.default_url_options[:host]
    )
  end
  delegate :mailer_host, to: self

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.guest_mailer.manual_upload_conversion_complete.subject
  #
  def manual_upload_conversion_complete(email:, source_files:)
    @source_files = source_files
    @host = mailer_host

    subject = "Your standards are live in the Apprenticeship Standards Library"
    mail to: email, bcc: MAILER_BCC, subject:
  end

  def manual_submissions_during_period(date_range:, email:, source_files:)
    @from = strftime(date_range.begin)
    @through = strftime(date_range.end)
    @host = mailer_host
    @source_files = source_files

    standards_count = source_files.sum { |file| file.associated_occupation_standards.count }
    if standards_count.positive?
      subject = "Standards converted in the Apprenticeship Standards Library " \
                "from #{@from}, through #{@through}."
      mail to: email, bcc: MAILER_BCC, subject:
    end
  end

  private

  def strftime(date)
    date.strftime("%b. %e, %Y")
  end
end
