class GuestMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.guest_mailer.manual_upload_conversion_complete.subject
  #
  def manual_upload_conversion_complete(email:, source_files:)
    @source_files = source_files

    mail to: email,
         subject: "Standards conversion completion"
  end
end
