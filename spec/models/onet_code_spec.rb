require "rails_helper"

RSpec.describe OnetCode, type: :model do
  it "has a valid factory" do
    onet_code = build(:onet_code)

    expect(onet_code).to be_valid
  end
end
