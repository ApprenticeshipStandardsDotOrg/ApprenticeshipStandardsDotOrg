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
