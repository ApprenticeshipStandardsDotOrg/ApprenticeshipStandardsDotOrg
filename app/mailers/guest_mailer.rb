class GuestMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.guest_mailer.manual_upload_conversion_complete.subject
  #
  def manual_upload_conversion_complete(email:, source_files:)
    @source_files = source_files
    @host = ENV.fetch("PUBLIC_DOMAIN", Rails.application.config.action_mailer.default_url_options[:host])

    mail to: email,
      subject: "Your standards are live in the Apprenticeship Standards Library"
  end
end
