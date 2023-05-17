require "rails_helper"

RSpec.describe Industry, type: :model do
  it "has a valid factory" do
    industry = build(:industry)

    expect(industry).to be_valid
  end

  it "is unique wrt prefix, version" do
    create(:industry, prefix: "11", version: "2018")
    industry = build(:industry, prefix: "11", version: "2018")

    expect(industry).to_not be_valid
    industry.version = "2022"
    expect(industry).to be_valid
  end
end
