require "rails_helper"

RSpec.describe "NationalStandards", type: :request do
  describe "GET /index" do
    context "when guest" do
      it "returns http success" do
        create_pair(:occupation_standard)

        get national_standards_path

        expect(response).to be_successful
      end
    end
  end

  describe "GET /show/:id" do
    context "with valid standard type" do
      it "returns http success" do
        create(:occupation_standard, :program_standard)

        get national_standard_path(:program_standard)

        expect(response).to be_successful
      end
    end

    context "with invalid standard type" do
      it "redirects to national_standards page" do
        get national_standard_path(:foobar)

        expect(response).to redirect_to national_standards_path
      end
    end
  end
end
