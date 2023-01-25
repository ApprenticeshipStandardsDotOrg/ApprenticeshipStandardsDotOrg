require "rails_helper"

RSpec.describe ImportOccupationStandardRelatedInstruction do
  describe "#call" do
    it "return related instruction record and create course and organization" do
      occupation_standard = create(:occupation_standard)
      tools_org = create(:organization, title: "Tools R Us")
      tools_course = create(:course, title: "Intro to Tools", description: "Learn all about how tools are used", code: "T001", hours: 50, organization: tools_org)

      data_import = create(:data_import)

      related_instructions = described_class.new(
        occupation_standard: occupation_standard,
        data_import: data_import
      ).call

      rsi1 = related_instructions.first
      expect(rsi1.occupation_standard).to eq occupation_standard
      expect(rsi1.sort_order).to eq 1
      expect(rsi1.course_title).to eq "Welding"
      expect(rsi1.course_description).to eq "Learn to Weld"
      expect(rsi1.course_code).to eq "W001"
      expect(rsi1.course_hours).to eq 30
      expect(rsi1.organization_title).to eq "Welders R Us"

      rsi2 = related_instructions.second
      expect(rsi2.occupation_standard).to eq occupation_standard
      expect(rsi2.sort_order).to eq 2
      expect(rsi2.course_title).to eq "Welding"
      expect(rsi2.course_description).to eq "Learn to Weld"
      expect(rsi2.course_code).to eq "W001"
      expect(rsi2.course_hours).to eq 30
      expect(rsi2.organization_title).to eq "Welders R Us"

      rsi3 = related_instructions.third
      expect(rsi3.occupation_standard).to eq occupation_standard
      expect(rsi3.sort_order).to eq 3
      expect(rsi3.course_title).to eq "Intro to Tools"
      expect(rsi3.course_description).to eq "Learn all about how tools are used"
      expect(rsi3.course_code).to eq "T001"
      expect(rsi3.course_hours).to eq 50
      expect(rsi3.organization_title).to eq "Tools R Us"
    end
  end
end
