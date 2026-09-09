require "rails_helper"

RSpec.describe OccupationStandardSocTargets do
  describe "#occupation_standards" do
    it "matches standards by or without an O*NET decimal suffix" do
      with_suffix = create(:occupation_standard, onet_code: "29-2034.00")
      without_suffix = create(:occupation_standard, onet_code: "29-2034")
      create(:occupation_standard, onet_code: "29-1141.00")

      result = described_class.new(codes: ["29-2034"]).occupation_standards

      expect(result).to contain_exactly(with_suffix, without_suffix)
    end
  end

  describe ".from_environment" do
    it "accepts comma- or space-separated overrides" do
      ENV["SOC_CODES"] = "29-2034, 13-2011"

      expect(described_class.from_environment.codes).to eq %w[13-2011 29-2034]
    ensure
      ENV.delete("SOC_CODES")
    end
  end
end
