require "rails_helper"

RSpec.describe Onet, type: :model do
  it "has a valid factory" do
    onet = build(:onet)

    expect(onet).to be_valid
  end

  it "has unique code wrt version" do
    onet = create(:onet, code: "12-3456.00", version: "2019")
    new_onet = build(:onet, code: "12-3456.00", version: "2019")

    expect(new_onet).to_not be_valid

    new_onet.version = "2020"
    expect(new_onet).to be_valid
  end
end
