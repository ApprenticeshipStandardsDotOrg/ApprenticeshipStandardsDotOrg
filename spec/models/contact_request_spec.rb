require "rails_helper"

RSpec.describe ContactRequest, type: :model do
  it "has a valid factory" do
    contact_request = build(:contact_request)

    expect(contact_request).to be_valid
  end
end
