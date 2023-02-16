class AdminMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.admin_mailer.new_standards_import.subject
  #
  def new_standards_import(standards_import)
    @standards_import = standards_import

    mail to: "jeanine@thoughtbot.com",
      subject: "New standards import uploaded"
  end
end
