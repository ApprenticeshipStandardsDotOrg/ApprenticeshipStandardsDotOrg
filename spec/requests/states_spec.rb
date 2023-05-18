require "rails_helper"

RSpec.describe "State", type: :request do
  describe "GET /index" do
    context "when guest" do
      it "returns http success" do
        create_pair(:state)

        get states_path

        expect(response).to be_successful
      end
    end
  end
end
