require "rails_helper"

RSpec.describe APIKey, type: :model do
  it "has a valid factory" do
    api_key = build(:api_key)

    expect(api_key).to be_valid
  end
end
