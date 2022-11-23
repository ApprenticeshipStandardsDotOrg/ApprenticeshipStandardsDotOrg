require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  describe "GET /new" do
    context "on admin subdomain" do
      it "is successful", :admin do
        get new_user_session_path

        expect(response).to be_successful
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        expect{
          get new_user_session_path
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe "GET /create" do
    it "redirects to file imports path", :admin do
      user = create(:admin)

      post user_session_path, params: {
        user: {email: user.email, password: user.password}
      }

      expect(response).to redirect_to file_imports_path
    end
  end
end
