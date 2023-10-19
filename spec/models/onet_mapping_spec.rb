require "rails_helper"

RSpec.describe OnetMapping, type: :model do
  it "has a valid factory" do
    onet_mapping = build(:onet_mapping)

    expect(onet_mapping).to be_valid
  end
end
