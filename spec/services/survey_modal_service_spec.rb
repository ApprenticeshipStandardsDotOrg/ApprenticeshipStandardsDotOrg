require "rails_helper"

RSpec.describe SurveyModalService do
  include ActiveSupport::Testing::TimeHelpers

  let(:cookies) { TestCookieJar.new }
  let(:service) { described_class.new(cookies) }

  after { travel_back }

  it "shows the modal after the second standards visit" do
    expect(service.show?).to be false

    service.upsert_cookie!
    expect(service.show?).to be false

    service.upsert_cookie!
    expect(service.show?).to be true
  end

  it "follows dismissal recurrence intervals" do
    service.upsert_cookie!
    service.upsert_cookie!

    service.mark_as_dismissed!
    expect(service.show?).to be false

    travel 8.days
    expect(service.show?).to be true

    service.mark_as_dismissed!
    expect(service.show?).to be false

    travel 1.month + 1.day
    expect(service.show?).to be true

    service.mark_as_dismissed!
    expect(service.show?).to be false

    travel 3.months + 1.day
    expect(service.show?).to be true

    service.mark_as_dismissed!
    expect(service.show?).to be false

    travel 2.years
    expect(service.show?).to be false
  end

  it "does not show the modal after submission" do
    service.upsert_cookie!
    service.upsert_cookie!

    expect(service.show?).to be true

    service.mark_as_submitted!

    travel 1.year
    expect(service.show?).to be false
  end

  class TestCookieJar
    attr_reader :encrypted

    def initialize
      @encrypted = {}
    end
  end
end
