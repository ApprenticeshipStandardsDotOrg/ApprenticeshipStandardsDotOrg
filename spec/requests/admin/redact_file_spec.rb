require "rails_helper"

RSpec.describe "Admin::SourceFiles::RedactFile", type: :request do
  describe "GET /new" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          active_storage_attachment = create(:active_storage_attachment)
          source_file = create(:source_file, active_storage_attachment: active_storage_attachment)

          sign_in admin
          get new_admin_source_file_redact_file_path(source_file)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "returns http success" do
          admin = create(:user, :converter)
          active_storage_attachment = create(:active_storage_attachment)
          source_file = create(:source_file, active_storage_attachment: active_storage_attachment)

          sign_in admin
          get new_admin_source_file_redact_file_path(source_file)

          expect(response).to be_successful
        end
      end

      context "when guest" do
        it "redirects to root path" do
          active_storage_attachment = create(:active_storage_attachment)
          source_file = create(:source_file, active_storage_attachment: active_storage_attachment)

          get new_admin_source_file_redact_file_path(source_file)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        active_storage_attachment = create(:active_storage_attachment)
        source_file = create(:source_file, active_storage_attachment: active_storage_attachment)
        expect {
          get new_admin_source_file_redact_file_path(source_file)
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
