require "rails_helper"

RSpec.describe "Admin::SourceFiles", type: :request do
  describe "GET /index" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          create_pair(:standards_import, :with_files)

          sign_in admin
          get admin_source_files_path

          expect(response).to be_successful
        end
      end

      context "when guest" do
        it "redirects to root path" do
          get admin_source_files_path

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        expect {
          get admin_source_files_path
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe "GET /show" do
    it "returns http success", :admin do
      admin = create(:admin)
      file = create(:source_file)

      sign_in admin
      get edit_admin_source_file_path(file)

      expect(response).to be_successful
    end
  end

  describe "GET /edit/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          file = create(:source_file)

          sign_in admin
          get edit_admin_source_file_path(file)

          expect(response).to be_successful
        end
      end

      context "when guest" do
        it "redirects to root path" do
          file = create(:source_file)
          get edit_admin_source_file_path(file)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        file = create(:source_file)
        expect {
          get edit_admin_source_file_path(file)
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe "PUT /update/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "updates record and redirects to index" do
          admin = create(:admin)
          file = create(:source_file)

          sign_in admin
          file_params = {
            source_file: {
              status: "completed"
            }
          }
          patch admin_source_file_path(file), params: file_params
          expect(file.reload).to be_completed
          expect(response).to redirect_to admin_source_files_path
        end
      end
    end
  end

  describe "DELETE /destroy" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "deletes record" do
          admin = create(:admin)
          file = create(:source_file)

          sign_in admin
          expect {
            delete admin_source_file_path(file)
          }.to change(SourceFile, :count).by(-1)
        end
      end
    end
  end
end
