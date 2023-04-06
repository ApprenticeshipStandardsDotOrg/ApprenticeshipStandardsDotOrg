require "rails_helper"

RSpec.describe APIKey, type: :model do
  it "has a valid factory" do
    api_key = build(:api_key)

    expect(api_key).to be_valid
  end

  describe "#token" do
    it "returns a non-nil token" do
      api_key = create(:api_key)

      expect(api_key.token).to_not be_nil
    end
  end
end
