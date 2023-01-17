require "rails_helper"

RSpec.describe OccupationStandard, type: :model do
  it "has a valid factory" do
    occupation_standard = build(:occupation_standard)

    expect(occupation_standard).to be_valid
  end

  describe "#rapids_code" do
    it "returns occupation rapids_code when occupation exists" do
      occupation = build_stubbed(:occupation, rapids_code: "abc")
      occupation_standard = build(:occupation_standard, occupation: occupation)

      expect(occupation_standard.rapids_code).to eq "abc"
    end

    it "returns nil when no occupation" do
      occupation_standard = build(:occupation_standard, occupation: nil)

      expect(occupation_standard.rapids_code).to be_nil
    end
  end

  describe "#onet_code" do
    it "returns occupation onet_code string when occupation and onet_code exists" do
      onet_code = build_stubbed(:onet_code, code: "abc")
      occupation = build_stubbed(:occupation, onet_code: onet_code)
      occupation_standard = build(:occupation_standard, occupation: occupation)

      expect(occupation_standard.onet_code).to eq "abc"
    end

    it "returns nil when occupation exists but onet_code does not" do
      occupation = build_stubbed(:occupation, onet_code: nil)
      occupation_standard = build(:occupation_standard, occupation: occupation)

      expect(occupation_standard.onet_code).to be_nil
    end

    it "returns nil when no occupation" do
      occupation_standard = build(:occupation_standard, occupation: nil)

      expect(occupation_standard.onet_code).to be_nil
    end
  end
end
