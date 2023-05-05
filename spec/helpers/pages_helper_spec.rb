require "rails_helper"

# Specs in this file have access to a helper object that includes
# the PagesHelper. For example:
#
# describe PagesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe PagesHelper, type: :helper do
  describe "#standards_by_state_count" do
    it "returns count of standards in passed state" do
      wa = create(:state, name: "Washington")
      ra = create(:registration_agency, state: wa)
      create(:occupation_standard, registration_agency: ra)
      create(:occupation_standard, registration_agency: ra)
      create(:occupation_standard)

      expect(helper.standards_by_state_count(wa)).to eq 2
    end
  end
end
