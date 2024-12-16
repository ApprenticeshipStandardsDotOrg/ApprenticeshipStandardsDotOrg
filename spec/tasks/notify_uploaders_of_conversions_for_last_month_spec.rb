require "rails_helper"
require "rake"

RSpec.describe "notify_uploaders_of_conversions_for_last_month" do
  Rake.application.rake_require "tasks/standards_import"
  Rake::Task.define_task(:environment)

  ActiveJob::Base.queue_adapter = :test

  include ActiveSupport::Testing::TimeHelpers
  RSpec::Matchers.define_negated_matcher :not_have_enqueued_job, :have_enqueued_job

  before do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    Rake.application.clear
    Rake.application.load_rakefile
  end

  after do
    Rake.application.clear
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end

  it "processes if today is the first day of the month and a weekday" do
    expected_date_range = Date.new(2024, 7, 1)..Date.new(2024, 7, 31)
    travel_to Time.zone.local(2024, 8, 1, 11, 0, 0) do # Thursday, August 1, 2024, 11:00am
      expect { Rake.application.invoke_task "standards_import:notify_uploaders_of_conversions_for_last_month" }
        .to have_enqueued_job(NotifyUploadsOfConversionsForPeriodJob).with(date_range: expected_date_range)
        .and output(/Running monthly conversion/).to_stdout
    end
  end

  it "processes if today is the Monday following a first day of the month that was on a weekend" do
    expected_date_range = Date.new(2024, 8, 1)..Date.new(2024, 8, 31)
    travel_to Time.local(2024, 9, 2, 11, 0, 0) do # Monday, September 2, 2024, 11:00am
      expect { Rake.application.invoke_task "standards_import:notify_uploaders_of_conversions_for_last_month" }
        .to have_enqueued_job(NotifyUploadsOfConversionsForPeriodJob).with(date_range: expected_date_range)
        .and output(/Running monthly conversion/).to_stdout
    end
  end

  it "does not processes if today is the first day of the month when that lands on a weekend" do
    travel_to Time.local(2024, 9, 1, 11, 0, 0) do # Sunday, September 1, 2024, 11:00am
      expect { Rake.application.invoke_task "standards_import:notify_uploaders_of_conversions_for_last_month" }
        .to output(/Not the first day of the month/).to_stdout
        .and not_have_enqueued_job(NotifyUploadsOfConversionsForPeriodJob)
    end
  end

  it "does not processes if today is a weekday but is not the first day of the month" do
    travel_to Time.local(2024, 8, 6, 11, 0, 0) do # Tuesday, August 6, 2024, 11:00am
      expect { Rake.application.invoke_task "standards_import:notify_uploaders_of_conversions_for_last_month" }
        .to output(/Not the first day of the month/).to_stdout
        .and not_have_enqueued_job(NotifyUploadsOfConversionsForPeriodJob)
    end
  end
end
