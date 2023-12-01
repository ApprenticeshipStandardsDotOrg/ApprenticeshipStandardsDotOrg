require "rails_helper"

# Specs in this file have access to a helper object that includes
# the RelatedInstructionsHelper. For example:
#
# describe RelatedInstructionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe RelatedInstructionsHelper, type: :helper do
  describe "#related_instruction_accordion_class" do
    it "returns nil if related_instruction has no details to display" do
      related_instruction = build(:related_instruction)
      allow(related_instruction).to receive(:has_details_to_display?).and_return(false)

      expect(helper.related_instruction_accordion_class(related_instruction)).to be_nil
    end

    it "returns 'accordion' if related_instruction has details to display" do
      related_instruction = build(:related_instruction)
      allow(related_instruction).to receive(:has_details_to_display?).and_return(true)

      expect(helper.related_instruction_accordion_class(related_instruction)).to eq "accordion"
    end
  end

  describe "#related_instruction_hours_display_class" do
    it "returns invisible if related_instruction hours field is nil" do
      related_instruction = build(:related_instruction, hours: nil)

      expect(helper.related_instruction_hours_display_class(related_instruction)).to eq "invisible"
    end

    it "returns invisible if related_instruction hours is 0" do
      related_instruction = build(:related_instruction, hours: 0)

      expect(helper.related_instruction_hours_display_class(related_instruction)).to eq "invisible"
    end

    it "returns visible if related_instruction hours is > 0" do
      related_instruction = build(:related_instruction, hours: 5)

      expect(helper.related_instruction_hours_display_class(related_instruction)).to eq "visible"
    end
  end
end
