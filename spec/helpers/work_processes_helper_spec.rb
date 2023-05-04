require "rails_helper"

# Specs in this file have access to a helper object that includes
# the WorkProcessesHelper. For example:
#
# describe WorkProcessesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe WorkProcessesHelper, type: :helper do
  describe "#hours_range" do
    it "returns the range with a hyphen when different min and max" do
      work_process = build(:work_process, minimum_hours: 10, maximum_hours: 20)

      expect(helper.hours_range(work_process)).to eq "10-20"
    end

    it "returns a single value when min and max are the same" do
      work_process = build(:work_process, minimum_hours: 10, maximum_hours: 10)

      expect(helper.hours_range(work_process)).to eq "10"

    end

    it "returns a single value when min is present and max is nil" do
      work_process = build(:work_process, minimum_hours: 10, maximum_hours: nil)

      expect(helper.hours_range(work_process)).to eq "10"
    end

    it "returns a single value when max is present and min is nil" do
      work_process = build(:work_process, minimum_hours: nil, maximum_hours: 10)
    end
  end

  describe "#hours_in_human_format" do
    it "returns 1K for 1,000" do
      expect(helper.hours_in_human_format(1000)).to eq "1K"
    end

    it "returns number with precision of 2" do
      expect(helper.hours_in_human_format(1234)).to eq "1.2K"
    end

    it "returns number without letter if lesser than 1,000" do
      expect(helper.hours_in_human_format(500)).to eq "500"
    end
  end
end
