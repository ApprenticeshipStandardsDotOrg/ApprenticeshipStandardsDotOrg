require "rails_helper"

RSpec.describe Competency, type: :model do
  it "has a valid factory" do
    competency = build(:competency)

    expect(competency).to be_valid
  end

  it "has unique state wrt agency_type" do
    competency = create(:competency, sort_order: 1)
    new_competency = build(:competency, work_process: competency.work_process, sort_order: 1)

    expect(new_competency).to_not be_valid
    new_competency.sort_order = 2
    expect(new_competency).to be_valid
  end

  describe ".from_json" do
    it "gets the attributes from a JSON input" do
      attributes = {
        "title" => "Clean workstation.",
        "description" => "Keep work stations clean and sanitize tools, such as scissors and combs."
      }
      competency = described_class.from_json(attributes)
      expect(competency.title).to eq attributes["title"]
      expect(competency.description).to eq attributes["description"]
    end
  end
end
