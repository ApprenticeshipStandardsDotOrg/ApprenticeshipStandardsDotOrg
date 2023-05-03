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

      context "when converter" do
        it "returns http success" do
          admin = create(:user, :converter)
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

  describe "GET /show", :admin do
    context "when admin" do
      it "returns http success" do
        admin = create(:admin)
        file = create(:source_file)

        sign_in admin
        get admin_source_file_path(file)

        expect(response).to be_successful
      end
    end

    context "when converter" do
      it "returns http success" do
        admin = create(:user, :converter)
        file = create(:source_file)

        sign_in admin
        get admin_source_file_path(file)

        expect(response).to be_successful
      end
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

      context "when converter" do
        it "redirects" do
          admin = create(:user, :converter)
          file = create(:source_file)

          sign_in admin
          get edit_admin_source_file_path(file)

          expect(response).to redirect_to root_path
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

      context "when converter" do
        it "can update assignee only" do
          assignee = create(:user, :converter)
          admin = create(:user, :converter)
          file = create(:source_file)

          sign_in admin
          file_params = {
            source_file: {
              status: "completed",
              assignee_id: assignee.id
            }
          }
          patch admin_source_file_path(file), params: file_params

          file.reload
          expect(file).to be_pending
          expect(file.assignee).to eq assignee
          expect(response).to redirect_to admin_source_files_path
        end

        it "will redirect back to redirect_to param" do
          assignee = create(:user, :converter)
          admin = create(:user, :converter)
          file = create(:source_file)

          sign_in admin
          file_params = {
            source_file: {
              status: "completed",
              assignee_id: assignee.id
            },
            redirect_back_to: admin_source_files_path(_page: 3)
          }
          patch admin_source_file_path(file), params: file_params

          expect(response).to redirect_to admin_source_files_path(_page: 3)
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
          expect(response).to redirect_to root_path
        end
      end

      context "when converter" do
        it "does not delete record" do
          admin = create(:user, :converter)
          file = create(:source_file)

          sign_in admin
          expect {
            delete admin_source_file_path(file)
          }.to_not change(SourceFile, :count)
          expect(response).to redirect_to root_path
        end
      end
    end
  end
end
