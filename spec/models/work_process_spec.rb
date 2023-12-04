require "rails_helper"

RSpec.describe WorkProcess, type: :model do
  it "has a valid factory" do
    wp = build(:work_process)

    expect(wp).to be_valid
  end

  describe "#hours" do
    it "returns maximum hours if present" do
      work_process = build(:work_process, maximum_hours: 1000, minimum_hours: 500)

      expect(work_process.hours).to eq 1000
    end

    it "returns minimum_hours if maximum_hours is not present" do
      work_process = build(:work_process, maximum_hours: nil, minimum_hours: 500)

      expect(work_process.hours).to eq 500
    end

    it "returns nil if minimum_hours and maximum_hours are not present" do
      work_process = build(:work_process, maximum_hours: nil, minimum_hours: nil)

      expect(work_process.hours).to eq nil
    end
  end

  describe "#has_details_to_display?" do
    it "returns false if work_process description is blank and there are no competencies" do
      work_process = build(:work_process, description: nil)

      expect(work_process).to_not have_details_to_display
    end

    it "returns true if work_process description is present but there are no competencies" do
      work_process = build(:work_process, description: "desc")

      expect(work_process).to have_details_to_display
    end

    it "returns true if work_process description is blank but there are competencies" do
      competency = build(:competency)
      work_process = build_stubbed(:work_process, description: nil, competencies: [competency])

      expect(work_process).to have_details_to_display
    end
  end
end
