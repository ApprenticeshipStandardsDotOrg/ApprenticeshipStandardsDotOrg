class NewOpenAIImportAvailableNotifier < ApplicationNotifier
  deliver_by :email do |config|
    config.mailer = "AdminMailer"
    config.method = :new_open_ai_import_available
    config.params = -> { params }
  end
end
