require "rails_helper"

RSpec.describe RelatedInstruction, type: :model do
  it "has a valid factory" do
    related_instruction = build(:related_instruction)

    expect(related_instruction).to be_valid
  end

  it "has unique sort_order, title, and code wrt occupation_standard" do
    related_instruction = create(:related_instruction, sort_order: 1, title: "Typing", code: "T001")
    new_related_instruction = build(:related_instruction,
      occupation_standard: related_instruction.occupation_standard, sort_order: 1, title: "Typing", code: "T001")

    expect(new_related_instruction).to_not be_valid
    new_related_instruction.sort_order = 2
    new_related_instruction.title = "Typing II"
    new_related_instruction.code = "T002"
    expect(new_related_instruction).to be_valid
  end

  describe ".from_json" do
    it "extracts the attributes for the related instruction" do
      attributes = {
        "title" => "Laborer Level 100-1",
        "description" => "Introduction to Construction Math",
        "code" => "100-1",
        "hours" => 8,
        "organization" => "National Center for Construction Education"
      }
      related_instructions = described_class.from_json(attributes)

      expect(related_instructions.title).to eq attributes["title"]
      expect(related_instructions.description).to eq attributes["description"]
      expect(related_instructions.code).to eq attributes["code"]
      expect(related_instructions.hours).to eq attributes["hours"]
    end
  end

  describe "#has_details_to_display?" do
    it "is false if description is nil" do
      related_instruction = build(:related_instruction, description: nil)

      expect(related_instruction).to_not have_details_to_display
    end

    it "is false if description is empty" do
      related_instruction = build(:related_instruction, description: "")

      expect(related_instruction).to_not have_details_to_display
    end

    it "is true if description not blank" do
      related_instruction = build(:related_instruction, description: "desc")

      expect(related_instruction).to have_details_to_display
    end
  end
end
