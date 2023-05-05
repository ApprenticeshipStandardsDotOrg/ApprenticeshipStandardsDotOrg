require "rails_helper"

RSpec.describe "StateStandards", type: :request do
  describe "GET /index" do
    context "when guest" do
      it "returns http success" do
        create_pair(:occupation_standard, :state_standard, :with_data_import)

        get state_standards_path

        expect(response).to be_successful
      end
    end
  end
end
