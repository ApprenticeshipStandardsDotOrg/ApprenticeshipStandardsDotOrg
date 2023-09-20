require "rails_helper"

RSpec.describe "Occupation", type: :request do
  describe "GET /index.json", :elasticsearch do
    it "returns a json response" do
      create(:occupation, title: "Mechanic")

      Occupation.import
      Occupation.__elasticsearch__.refresh_index!

      get occupations_path, params: {format: "json", q: "Mech"}

      expect(response_json[0][:display]).to eq "Mechanic"
      expect(response_json[0][:link]).to eq "/occupations"

      expect(response).to be_successful
      expect(response.content_type).to eq "application/json; charset=utf-8"
    end
  end
end
