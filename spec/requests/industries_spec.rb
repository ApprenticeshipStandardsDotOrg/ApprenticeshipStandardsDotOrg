require "rails_helper"

RSpec.describe "Industry", type: :request do
  describe "GET /index" do
    context "when guest" do
      it "returns http success" do
        create_pair(:industry)

        get industries_path

        expect(response).to be_successful
      end
    end
  end
end
