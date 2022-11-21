require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  describe "GET /create" do
    it "redirects to file imports path" do
      user = create(:admin)

      post user_session_path, params: {
        user: {email: user.email, password: user.password}
      }

      expect(response).to redirect_to file_imports_path
    end
  end
end
