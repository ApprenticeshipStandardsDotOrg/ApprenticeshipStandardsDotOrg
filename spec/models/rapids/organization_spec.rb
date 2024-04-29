require "rails_helper"

RSpec.describe RAPIDS::Organization, type: :model do
  describe ".initialize_from_response" do
    it "returns organization with correct data" do
      occupation_standard_response = create(:rapids_api_occupation_standard, sponsorName: "thoughtbot")

      organization = RAPIDS::Organization.initialize_from_response(occupation_standard_response)

      expect(organization.title).to eq "thoughtbot"
      expect(organization.sponsor_number).to eq occupation_standard_response["sponsorNumber"]
    end
  end
end
