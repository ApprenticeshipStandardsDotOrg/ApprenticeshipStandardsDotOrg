require "rails_helper"

RSpec.describe "Admin::SourceFiles::RedactFile", type: :request do
  describe "GET /redact_file/new" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          import = create(:imports_pdf)

          sign_in admin
          get new_admin_import_redact_file_path(import)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "returns http success" do
          admin = create(:user, :converter)
          import = create(:imports_pdf)

          sign_in admin
          get new_admin_import_redact_file_path(import)

          expect(response).to be_successful
        end
      end

      context "when guest" do
        it "redirects to root path" do
          import = create(:imports_pdf)

          get new_admin_import_redact_file_path(import)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        import = create(:imports_pdf)

        get new_admin_import_redact_file_path(import)

        expect(response).to be_not_found
      end
    end
  end

  describe "POST /redact_file" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        context "without redacted file" do
          it "returns http success" do
            admin = create(:admin)
            import = create(:imports_pdf)

            sign_in admin
            post admin_import_redact_file_path(import), as: :json

            expect(response).to be_successful
            expect(import.reload.redacted_at).to be nil
          end
        end

        context "with redacted file" do
          it "returns http success" do
            travel_to Time.current do
              admin = create(:admin)
              import = create(:imports_pdf)
              redacted_file = fixture_file_upload("pixel1x1.jpg", "image/jpeg")

              sign_in admin
              post admin_import_redact_file_path(import), params: {
                format: :json,
                redacted_file: redacted_file
              }

              expect(response).to be_successful
              expect(import.reload.redacted_at).to eq Time.current
              expect(import.redacted_pdf).to be_attached
            end
          end
        end

        context "without occupation standard" do
          it "only updates redacted import" do
            travel_to Time.current do
              admin = create(:admin)
              data_import = create(:data_import, occupation_standard: nil)
              import = create(:imports_pdf, data_imports: [data_import])
              redacted_file = fixture_file_upload("pixel1x1.jpg", "image/jpeg")

              params = {
                format: :json,
                redacted_file: redacted_file
              }

              sign_in admin
              post admin_import_redact_file_path(import), params: params

              expect(response).to be_successful
              expect(import.reload.redacted_at).to eq Time.current
              expect(import.redacted_pdf).to be_attached
            end
          end
        end
      end
    end
  end
end
