# To deliver this notification:
#
# NewOpenAIImportAvailableNotifier.with(record: @post, message: "New post").deliver(User.all)

class NewOpenAIImportAvailableNotifier < ApplicationNotifier
  deliver_by :email do |config|
    config.mailer = "AdminMailer"
    config.method = :new_open_ai_import_available
    config.params = -> { params }
  end
end
