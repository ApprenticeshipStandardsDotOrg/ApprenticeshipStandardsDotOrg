require "rails_helper"

RSpec.describe "DataImports", type: :request, admin: true do
  describe "GET /new" do
    it "returns http success" do
      get new_data_import_path

      expect(response).to be_successful
    end
  end
end