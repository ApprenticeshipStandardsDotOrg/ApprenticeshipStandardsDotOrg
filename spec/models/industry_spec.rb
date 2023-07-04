require "rails_helper"

RSpec.describe Industry, type: :model do
  describe ".popular" do
    it "returns industries order by the ones with the most occupation standards first" do
      tech = create(:industry, name: "Tech")
      trucking = create(:industry, name: "Trucking")
      create(:industry, name: "Eletrical")

      create_list(:occupation_standard, 2, industry: tech)
      create(:occupation_standard, industry: trucking)

      popular = described_class.popular(limit: 2)

      expect(popular.pluck(:name)).to match_array(["Tech", "Trucking"])
    end
  end

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
