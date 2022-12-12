class AdminMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.admin_mailer.new_standards_import.subject
  #
  def new_standards_import(standards_import)
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
