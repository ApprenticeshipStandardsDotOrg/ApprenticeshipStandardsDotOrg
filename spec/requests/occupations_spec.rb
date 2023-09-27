require "rails_helper"

RSpec.describe "Occupation", type: :request do
  describe "GET /index.json", :elasticsearch do
    it "returns a json response" do
      onet = create(:onet, code: "12-3456")
      create(:occupation, title: "Mechanic", rapids_code: "5678CB", onet: onet)

      Occupation.import
      Occupation.__elasticsearch__.refresh_index!

      get occupations_path, params: {format: "json", q: "Mech"}

      expect(response_json[0][:display]).to eq "Mechanic"
      expect(response_json[0][:link]).to eq "/occupation_standards"

      expect(response).to be_successful
      expect(response.content_type).to eq "application/json; charset=utf-8"

      get occupations_path, params: {format: "json", q: "12-34"}

      expect(response_json[0][:display]).to eq "Mechanic"
      expect(response_json[0][:link]).to eq "/occupation_standards"

      get occupations_path, params: {format: "json", q: "567"}

      expect(response_json[0][:display]).to eq "Mechanic"
      expect(response_json[0][:link]).to eq "/occupation_standards"
    end
  end
end
