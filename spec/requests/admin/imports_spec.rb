require "rails_helper"

RSpec.describe "Admin::Imports", type: :request do
  describe "GET /index" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          create_pair(:imports_uncategorized)

          sign_in admin
          get admin_imports_path

          expect(response).to be_successful
        end

        it "allows filtering by status" do
          admin = create(:admin)
          unfurled = create(:imports_uncategorized, status: "unfurled")
          archived = create(:imports_uncategorized, status: "archived")

          sign_in admin

          get admin_imports_path(search: "status:archived")

          expect(response).to be_successful
          expect(response.body).to include(archived.id)
          expect(response.body).not_to include(unfurled.id)
        end

        it "allows filtering by assignee name" do
          admin = create(:admin)
          benny = create(:user, :converter, name: "Benny")
          piper = create(:user, :converter, name: "Piper")
          import1 = create(:imports_uncategorized, assignee: benny)
          import2 = create(:imports_uncategorized, assignee: piper)

          sign_in admin

          get admin_imports_path(search: "assignee:ben")

          expect(response).to be_successful
          expect(response.body).to include(import1.id)
          expect(response.body).not_to include(import2.id)
        end

        it "allows filtering by standards import organization field" do
          admin = create(:admin)
          import = create(:imports_uncategorized)
          standards_import = import.parent
          standards_import.update!(organization: "Urban Institute")
          other_import = create(:imports_uncategorized)

          sign_in admin

          get admin_imports_path(search: "organization:urban")

          expect(response).to be_successful
          expect(response.body).to include(import.id)
          expect(response.body).not_to include(other_import.id)
        end

        it "allows filtering by public document" do
          admin = create(:admin)
          import_public = create(:imports_uncategorized, public_document: true)
          import_private = create(:imports_uncategorized, public_document: false)

          sign_in admin

          get admin_imports_path(search: "public_document:true")

          expect(response).to be_successful
          expect(response.body).to include(import_public.id)
          expect(response.body).not_to include(import_private.id)

          get admin_imports_path(search: "public_document:false")

          expect(response).to be_successful
          expect(response.body).to_not include(import_public.id)
          expect(response.body).to include(import_private.id)
        end

        it "allows filtering by filename" do
          admin = create(:admin)
          import_pdf = create(:imports_pdf)
          import_doc = create(:imports_doc)

          sign_in admin

          get admin_imports_path(search: "file:pixel")

          expect(response).to be_successful
          expect(response.body).to include(import_pdf.id)
          expect(response.body).not_to include(import_doc.id)
        end

        it "allows filtering by needs redaction" do
          admin = create(:admin)
          redacted = create(:imports_pdf, :with_redacted_pdf)
          not_redacted = create(:imports_pdf, status: :completed, public_document: false)

          sign_in admin

          get admin_imports_path(search: "needs_redaction:", pdf_only: true)

          expect(response).to be_successful
          expect(response.body).to include(not_redacted.id)
          expect(response.body).not_to include(redacted.id)
        end

        it "allows filtering by redacted" do
          admin = create(:admin)
          redacted = create(:imports_pdf, :with_redacted_pdf)
          not_redacted = create(:imports_pdf)

          sign_in admin

          get admin_imports_path(search: "redacted:", pdf_only: true)

          expect(response).to be_successful
          expect(response.body).to include(redacted.id)
          expect(response.body).not_to include(not_redacted.id)
        end
      end

      context "when converter" do
        it "returns http success" do
          admin = create(:user, :converter)
          create_pair(:imports_uncategorized)

          sign_in admin
          get admin_imports_path

          expect(response).to be_successful
        end

        it "allows filtering by needs redaction" do
          admin = create(:admin, :converter)
          redacted = create(:imports_pdf, :with_redacted_pdf)
          not_redacted = create(:imports_pdf, status: :completed, public_document: false)

          sign_in admin

          get admin_imports_path(search: "needs_redaction:")

          expect(response).to be_successful
          expect(response.body).to include(not_redacted.id)
          expect(response.body).not_to include(redacted.id)
        end

        it "allows filtering by redacted" do
          admin = create(:admin, :converter)
          redacted = create(:imports_pdf, :with_redacted_pdf)
          not_redacted = create(:imports_pdf)

          sign_in admin

          get admin_imports_path(search: "redacted:")

          expect(response).to be_successful
          expect(response.body).to include(redacted.id)
          expect(response.body).not_to include(not_redacted.id)
        end
      end

      context "when guest" do
        it "redirects to root path" do
          get admin_imports_path

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        get admin_imports_path

        expect(response).to be_not_found
      end
    end
  end

  describe "GET /show", :admin do
    context "when admin" do
      it "returns http success" do
        admin = create(:admin)
        import = create(:imports_uncategorized)

        sign_in admin
        get admin_import_path(import)

        expect(response).to be_successful
      end
    end

    context "when converter" do
      context "when Imports::Pdf type" do
        it "returns http success" do
          admin = create(:user, :converter)
          import = create(:imports_pdf)

          sign_in admin
          get admin_import_path(import)

          expect(response).to be_successful
        end
      end

      context "when not Imports::Pdf type" do
        it "returns 404" do
          admin = create(:user, :converter)
          import = create(:imports_uncategorized)

          sign_in admin
          get admin_import_path(import)

          expect(response).to be_not_found
        end
      end
    end
  end

  describe "GET /edit/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          import = create(:imports_uncategorized)

          sign_in admin
          get edit_admin_import_path(import)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects" do
          admin = create(:user, :converter)
          import = create(:imports_pdf)

          sign_in admin
          get edit_admin_import_path(import)

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          import = create(:imports_uncategorized)
          get edit_admin_import_path(import)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        import = create(:imports_uncategorized)

        get edit_admin_import_path(import)

        expect(response).to be_not_found
      end
    end
  end

  describe "PUT /update/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "updates record and redirects to index" do
          admin = create(:admin)
          import = create(:imports_uncategorized, status: :unfurled)

          sign_in admin
          patch admin_import_path(import), params: {
            imports_uncategorized: {
              status: "archived"
            }
          }

          expect(import.reload).to be_archived
          expect(response).to redirect_to admin_imports_path
        end
      end

      context "when converter" do
        it "can update assignee and status only" do
          assignee = create(:user, :converter)
          admin = create(:user, :converter)
          import = create(:imports_pdf)

          sign_in admin
          patch admin_import_path(import), params: {
            imports_pdf: {
              status: "needs_support",
              assignee_id: assignee.id,
              metadata: {foo: "bob"}.to_json
            }
          }

          import.reload
          expect(import).to be_needs_support
          expect(import.assignee).to eq assignee
          expect(import.metadata).to be_empty
          expect(response).to redirect_to admin_imports_path
        end

        it "will redirect back to redirect_to param" do
          assignee = create(:user, :converter)
          admin = create(:user, :converter)
          import = create(:imports_pdf)

          sign_in admin
          patch admin_import_path(import), params: {
            imports_pdf: {
              status: "completed",
              assignee_id: assignee.id
            },
            redirect_back_to: admin_imports_path(_page: 3)
          }

          expect(response).to redirect_to admin_imports_path(_page: 3)
        end
      end
    end
  end

  describe "DELETE /redacted_import" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "deletes redacted import" do
          admin = create(:admin)
          import = create(:imports_pdf, :with_redacted_pdf)

          sign_in admin

          expect {
            delete redacted_import_admin_import_path(import, attachment_id: import.redacted_pdf.id)
          }.to change(ActiveStorage::Attachment, :count).by(-1)
          expect(import.reload.redacted_pdf).to_not be_attached
          expect(response).to redirect_to admin_import_path(import)
        end
      end

      context "when converter" do
        it "does not delete redacted import" do
          admin = create(:user, :converter)
          import = create(:imports_pdf, :with_redacted_pdf)

          sign_in admin

          expect {
            delete redacted_import_admin_import_path(import, attachment_id: import.redacted_pdf.id)
          }.to_not change(ActiveStorage::Attachment, :count)
          expect(import.reload.redacted_pdf).to be_attached
          expect(response).to redirect_to root_path
        end
      end
    end
  end
end
