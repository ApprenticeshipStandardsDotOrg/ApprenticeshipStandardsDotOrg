require "rails_helper"

RSpec.describe "WorkProcesses", type: :request do
  describe "GET /index" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          create(:work_process)

          sign_in admin
          get new_work_process_path

          expect(response).to be_successful
        end
      end

      context "when guest" do
        it "redirects to root path" do
          get new_work_process_path

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        expect {
          get new_work_process_path
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
