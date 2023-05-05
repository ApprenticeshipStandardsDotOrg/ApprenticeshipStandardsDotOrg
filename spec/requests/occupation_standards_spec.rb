require "rails_helper"

RSpec.describe "OccupationStandard", type: :request do
  describe "GET /index" do
    context "when guest" do
      it "returns http success" do
        create_pair(:occupation_standard, :with_data_import)

        get occupation_standards_path

        expect(response).to be_successful
      end
    end
  end

  describe "GET /show/:id" do
    context "when guest" do
      it "returns http success" do
        occupation_standard = create(:occupation_standard, :with_data_import)

        get occupation_standard_path(occupation_standard)

        expect(response).to be_successful
      end
    end
  end
end
