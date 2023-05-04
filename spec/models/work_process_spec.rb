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
end
