require "rails_helper"

RSpec.describe "OccupationStandard", type: :request do
  describe "GET /index" do
    context "when guest" do
      it "returns http success" do
        create_pair(:occupation_standard, :with_work_processes, :with_data_import)

        get occupation_standards_path

        expect(response).to be_successful
      end
    end

    context "on staging" do
      it "returns unauthorized if no http basic auth credentials" do
        stub_const "ENV", ENV.to_h.merge("APP_ENVIRONMENT" => "staging", "BASIC_AUTH_USERNAME" => "admin", "BASIC_AUTH_PASSWORD" => "password")

        get occupation_standards_path

        expect(response).to be_unauthorized
      end

      it "returns unauthorized if incorrect http basic auth credentials passed" do
        stub_const "ENV", ENV.to_h.merge("APP_ENVIRONMENT" => "staging", "BASIC_AUTH_USERNAME" => "admin", "BASIC_AUTH_PASSWORD" => "password")
        authorization = ActionController::HttpAuthentication::Basic.encode_credentials("admin", "badpassword")

        get occupation_standards_path, headers: {"HTTP_AUTHORIZATION" => authorization}

        expect(response).to be_unauthorized
      end

      it "is successful if correct http basic auth credentials passed" do
        stub_const "ENV", ENV.to_h.merge("APP_ENVIRONMENT" => "staging", "BASIC_AUTH_USERNAME" => "admin", "BASIC_AUTH_PASSWORD" => "password")
        authorization = ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password")

        get occupation_standards_path, headers: {"HTTP_AUTHORIZATION" => authorization}

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

  describe "GET /show/:id.docx" do
    it "returns a docx document" do
      occupation_standard = create(:occupation_standard, :with_data_import)

      get occupation_standard_path(occupation_standard), params: {format: "docx"}

      docx_mime_type = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"

      expect(response).to be_successful
      expect(response.content_type).to eq docx_mime_type
    end

    describe "GET /index.json" do
      it "returns http success" do
        occupation_standard = create(:occupation_standard, :with_data_import, title: "Mechanic")

        get occupation_standards_path, params: {format: "json", q: "Mech"}

        expect(response).to be_successful
      end

      it "returns a json response" do
        occupation_standard = create(:occupation_standard, :with_data_import, title: "Mechanic")

        get occupation_standards_path, params: {format: "json", q: "Mech"}

        expect(response.content_type).to eq "application/json; charset=utf-8"
      end

      it "returns expected fields" do
        occupation_standard = create(:occupation_standard, :with_data_import, title: "Mechanic")

        get occupation_standards_path, params: {format: "json", q: "Mech"}
        parsed_response = JSON.parse(response.body)
        result = parsed_response.first

        expect(result["id"]).to eq occupation_standard.id
        expect(result["display"]).to eq occupation_standard.display_for_typeahead
        expect(result["link"]).to eq occupation_standard_path(occupation_standard)
      end

    end
  end
end
