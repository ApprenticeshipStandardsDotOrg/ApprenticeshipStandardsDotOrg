class NotifyUploadsOfConversionsForPeriodJob < ApplicationJob
  queue_as :default

  def perform(date_range:, email: nil)
    if !(date_range.is_a?(Range) && (date_range.begin.is_a?(Date) || date_range.begin.is_a?(Time)))
      raise InvalidDateRange, "must be a Range of Dates or Times"
    end

    StandardsImport.manual_submissions_during_period(date_range:, email:).each do |standards_import|
      GuestMailer.manual_submissions_during_period(
        date_range:,
        email: standards_import.email,
        source_files: standards_import.source_files_processed_during_period(date_range:, email:)
      ).deliver_now
    end
  end

  class InvalidDateRange < ArgumentError; end
end
