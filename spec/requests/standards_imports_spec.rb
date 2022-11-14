require "rails_helper"

RSpec.describe "StandardsImports", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get new_standards_import_path

      expect(response).to be_successful
    end
  end
end
