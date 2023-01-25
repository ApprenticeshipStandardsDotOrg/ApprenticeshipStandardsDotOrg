require "rails_helper"

RSpec.describe RelatedInstruction, type: :model do
  it "has a valid factory" do
    related_instruction = build(:related_instruction)

    expect(related_instruction).to be_valid
  end

  it "has unique sort_order wrt occupation_standard" do
    related_instruction = create(:related_instruction, sort_order: 1)
    new_related_instruction = build(:related_instruction,
      occupation_standard: related_instruction.occupation_standard, sort_order: 1)

    expect(new_related_instruction).to_not be_valid
    new_related_instruction.sort_order = 2
    expect(new_related_instruction).to be_valid
  end

  describe "#organization_title" do
    context "when course organization exists" do
      it "returns course organization title" do
        org = build_stubbed(:organization, title: "Some org")
        course = build_stubbed(:course, organization: org)
        ri = build(:related_instruction, course: course)

        expect(ri.organization_title).to eq "Some org"
      end
    end

    context "when course organization does not exist" do
      it "returns nil" do
        course = build_stubbed(:course, organization: nil)
        ri = build(:related_instruction, course: course)

        expect(ri.organization_title).to be_nil
      end
    end
  end
end
