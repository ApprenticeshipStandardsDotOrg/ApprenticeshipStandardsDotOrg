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

  describe "GET /show/:id.docx" do
    it "returns http ok" do
      occupation_standard = create(:occupation_standard, :with_data_import)

      get occupation_standard_path(occupation_standard), params: {format: "docx"}

      docx_mime_type = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"

      expect(response).to be_successful
      expect(response.content_type).to eq docx_mime_type
    end
  end
end
