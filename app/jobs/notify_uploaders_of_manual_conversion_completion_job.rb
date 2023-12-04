class NotifyUploadersOfManualConversionCompletionJob < ApplicationJob
  queue_as :default

  def perform(email: nil)
    StandardsImport.manual_submissions_in_need_of_courtesy_notification(email: email).each do |import|
      GuestMailer.manual_upload_conversion_complete(
        email: import.email,
        source_files: import.source_files_in_need_of_notification
      ).deliver_now

      import.source_files_in_need_of_notification.each do |source_file|
        source_file.courtesy_notification_completed!
      end

      if import.has_notified_uploader_of_all_conversions?
        import.courtesy_notification_completed!
      end
    end
  end
end
