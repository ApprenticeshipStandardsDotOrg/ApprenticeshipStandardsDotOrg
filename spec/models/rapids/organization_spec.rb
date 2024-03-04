require "rails_helper"

RSpec.describe RAPIDS::Organization, type: :model do
  describe ".initialize_from_response" do
    it "returns organization with correct data" do

      work_process_response = create(:rapids_api_occupation_standard, sponsorName: "thoughtbot")

      organization = RAPIDS::Organization.initialize_from_response(work_process_response)

      expect(organization.title).to eq "thoughtbot"
    end
  end
end
