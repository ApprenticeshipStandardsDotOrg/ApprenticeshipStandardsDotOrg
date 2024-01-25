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

      it "filters out archived source files by default" do
        sign_in(create(:admin))
        archived = create(:source_file, status: "archived")
        pending = create(:source_file, status: "pending")

        get(admin_source_files_path)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(pending.id)
        expect(response.body).not_to include(archived.id)
      end

      it "allows filtering by status" do
        sign_in(create(:admin))
        pending = create(:source_file, status: "pending")
        archived = create(:source_file, status: "archived")

        get(admin_source_files_path(search: "archived"))

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(archived.id)
        expect(response.body).not_to include(pending.id)
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        get admin_source_files_path

        expect(response).to be_not_found
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

        get edit_admin_source_file_path(file)

        expect(response).to be_not_found
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
        it "can update assignee and status only" do
          assignee = create(:user, :converter)
          admin = create(:user, :converter)
          file = create(:source_file)

          sign_in admin
          file_params = {
            source_file: {
              status: "needs_support",
              assignee_id: assignee.id,
              metadata: {foo: "bob"}.to_json
            }
          }
          patch admin_source_file_path(file), params: file_params

          file.reload
          expect(file).to be_needs_support
          expect(file.assignee).to eq assignee
          expect(file.metadata).to be_empty
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

  describe "DELETE /redacted_source_file" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "deletes redacted source file" do
          admin = create(:admin)
          file = create(:source_file, :with_redacted_source_file)

          sign_in admin
          expect {
            delete redacted_source_file_admin_source_file_path(file, attachment_id: file.redacted_source_file.id)
          }.to change(ActiveStorage::Attachment, :count).by(-1)
          expect(file.reload.redacted_source_file).to_not be_attached
          expect(response).to redirect_to admin_source_file_path(file)
        end
      end

      context "when converter" do
        it "does not delete redacted source file" do
          admin = create(:user, :converter)
          file = create(:source_file, :with_redacted_source_file)

          sign_in admin
          expect {
            delete redacted_source_file_admin_source_file_path(file, attachment_id: file.redacted_source_file.id)
          }.to_not change(ActiveStorage::Attachment, :count)
          expect(file.reload.redacted_source_file).to be_attached
          expect(response).to redirect_to root_path
        end
      end
    end
  end
end
