require "rails_helper"

# Specs in this file have access to a helper object that includes
# the OccupationStandardsHelper. For example:
#
# describe OccupationStandardsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe OccupationStandardsHelper, type: :helper do
  describe "#ojt_type_display" do
    it "returns nil if no ojt_type" do
      occupation_standard = build(:occupation_standard, ojt_type: nil)

      expect(helper.ojt_type_display(occupation_standard)).to be_nil
    end

    it "returns the ojt_type titleized" do
      occupation_standard = build(:occupation_standard, ojt_type: :hybrid)

      expect(helper.ojt_type_display(occupation_standard)).to eq "Hybrid"
    end
  end

  describe "#standard_descendants_accordion_class" do
    it "returns nil if related_instruction has no details to display" do
      related_instruction = build(:related_instruction)
      allow(related_instruction).to receive(:has_details_to_display?).and_return(false)

      expect(helper.standard_descendants_accordion_class(related_instruction)).to be_nil
    end

    it "returns 'accordion' if related_instruction has details to display" do
      related_instruction = build(:related_instruction)
      allow(related_instruction).to receive(:has_details_to_display?).and_return(true)

      expect(helper.standard_descendants_accordion_class(related_instruction)).to eq "accordion"
    end
  end

  describe "#standard_descendants_toggle_icon" do
    it "returns nil if related_instruction has no details to display" do
      related_instruction = build(:related_instruction)
      allow(related_instruction).to receive(:has_details_to_display?).and_return(false)

      expect(helper.standard_descendants_toggle_icon(related_instruction)).to be_nil
    end

    it "returns before content if related_instruction has details to display" do
      related_instruction = build(:related_instruction)
      allow(related_instruction).to receive(:has_details_to_display?).and_return(true)

      expect(helper.standard_descendants_toggle_icon(related_instruction)).to eq "before:content-['+']"
    end
  end

  describe "#filters_class" do
    it "returns hidden if no filter params" do
      expect(helper.filters_class).to eq "hidden"
    end

    it "returns nil if state filter params" do
      controller.params[:state_id] = "abc123"

      expect(helper.filters_class).to be_nil
    end

    it "returns nil if national_standard_type filter params" do
      params = {national_standard_type: {program_standard: "1"}}
      controller.params = params

      expect(helper.filters_class).to be_nil
    end

    it "returns nil if ojt_type filter params" do
      params = {ojt_type: {hybrid: "1"}}
      controller.params = params

      expect(helper.filters_class).to be_nil
    end
  end

  describe "#filters_aria_expanded" do
    it "returns false if no filter params" do
      expect(helper.filters_aria_expanded).to eq "false"
    end

    it "returns true if filter params" do
      controller.params[:state_id] = "abc123"

      expect(helper.filters_aria_expanded).to eq "true"
    end
  end

  describe "#sponsor_name" do
    it "returns anonymous when standard does not come from public document" do
      occupation_standard = build(:occupation_standard)
      allow(occupation_standard).to receive(:public_document?).and_return(false)

      expect(helper.sponsor_name(occupation_standard)).to eq "Anonymous"
    end

    it "returns organization name when standard does not come from public document" do
      occupation_standard = build(:occupation_standard)
      allow(occupation_standard).to receive(:public_document?).and_return(true)

      expect(helper.sponsor_name(occupation_standard)).to eq occupation_standard.organization_title
    end
  end
end
