require "rails_helper"

RSpec.describe "Users::Invitations", type: :request do
  describe "GET /new" do
    context "on admin subdomain", :admin do
      it "redirects to sign in path if not authenticated" do
        get new_user_invitation_path

        expect(response).to redirect_to new_user_session_path
      end

      it "redirects to root path if authenticated" do
        admin = create(:admin)

        sign_in admin
        get new_user_invitation_path

        expect(response).to redirect_to root_path
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        get new_user_invitation_path

        expect(response).to be_not_found
      end
    end
  end
end
