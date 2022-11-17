require "rails_helper"

RSpec.describe "StandardsImports", type: :request do
  describe "GET /index" do
    context "when admin user" do
      it "returns http success" do
        admin = create(:admin)

        sign_in admin
        get import_files_path

        expect(response).to be_successful
      end
    end

    context "when guest" do
      it "redirects to root path" do
        get import_files_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
