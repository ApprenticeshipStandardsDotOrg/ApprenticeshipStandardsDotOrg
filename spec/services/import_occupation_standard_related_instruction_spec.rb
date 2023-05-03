require "rails_helper"

RSpec.describe ImportOccupationStandardRelatedInstruction do
  describe "#call" do
    it "return related instruction record and create organization when present" do
      occupation_standard = create(:occupation_standard)
      data_import = create(:data_import)

      expect {
        described_class.new(
          occupation_standard: occupation_standard,
          data_import: data_import
        ).call
      }.to change(RelatedInstruction, :count).by(4)

      rsi1 = RelatedInstruction.first
      expect(rsi1.occupation_standard).to eq occupation_standard
      expect(rsi1.sort_order).to eq 1
      expect(rsi1.title).to eq "Welding"
      expect(rsi1.description).to eq "Learn to Weld"
      expect(rsi1.code).to eq "W001"
      expect(rsi1.hours).to eq 30
      expect(rsi1.organization_title).to eq "Welders R Us"

      rsi2 = RelatedInstruction.second
      expect(rsi2.occupation_standard).to eq occupation_standard
      expect(rsi2.sort_order).to eq 2
      expect(rsi2.title).to eq "Welding"
      expect(rsi2.description).to eq "Learn to Weld"
      expect(rsi2.code).to eq "W001"
      expect(rsi2.hours).to eq 40
      expect(rsi2.organization_title).to eq "Welders R Us"

      rsi3 = RelatedInstruction.third
      expect(rsi3.occupation_standard).to eq occupation_standard
      expect(rsi3.sort_order).to eq 3
      expect(rsi3.title).to eq "Intro to Tools"
      expect(rsi3.description).to eq "Learn about Tools"
      expect(rsi3.code).to eq "T001"
      expect(rsi3.hours).to eq 50
      expect(rsi3.organization_title).to eq "Tools R Us"

      rsi4 = RelatedInstruction.fourth
      expect(rsi4.occupation_standard).to eq occupation_standard
      expect(rsi4.sort_order).to eq 4
      expect(rsi4.title).to eq "Intro to Computers"
      expect(rsi4.description).to eq "Learn about computers"
      expect(rsi4.code).to eq "C001"
      expect(rsi4.hours).to eq 50
      expect(rsi4.organization).to be_nil
    end
  end
end
