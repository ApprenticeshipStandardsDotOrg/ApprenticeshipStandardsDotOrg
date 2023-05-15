require "rails_helper"

RSpec.describe "Admin::OccupationStandardExports", type: :request do
  describe "GET /show/:id", :admin do
    it "returns http ok" do
      admin = create(:admin)
      data_import = create(:data_import)
      occupation_standard = data_import.occupation_standard
  
      sign_in admin
      get admin_occupation_standard_export_path(occupation_standard)

      expect(response).to have_http_status(:ok)
    end
  end  
end
