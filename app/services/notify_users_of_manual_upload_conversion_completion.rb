class NotifyUsersOfManualUploadConversionCompletion
  attr_reader :email

  class << self
    def call(email: nil)
      new(email: email).call
    end
  end

  def initialize(email: nil)
    @email = email
  end

  def call
    StandardsImport.manual_submissions_in_need_of_courtesy_notification(email: email).each do |import|
      GuestMailer.manual_upload_conversion_complete(
        email: import.email,
        source_files: import.source_files_in_need_of_notification
      ).deliver_later
    end
  end
end
