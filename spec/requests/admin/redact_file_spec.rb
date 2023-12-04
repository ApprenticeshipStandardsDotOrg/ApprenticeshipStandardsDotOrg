require "rails_helper"

RSpec.describe "Admin::SourceFiles::RedactFile", type: :request do
  describe "GET /redact_file/new" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          source_file = create(:source_file)

          sign_in admin
          get new_admin_source_file_redact_file_path(source_file)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "returns http success" do
          admin = create(:user, :converter)
          source_file = create(:source_file)

          sign_in admin
          get new_admin_source_file_redact_file_path(source_file)

          expect(response).to be_successful
        end
      end

      context "when guest" do
        it "redirects to root path" do
          source_file = create(:source_file)

          get new_admin_source_file_redact_file_path(source_file)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        source_file = create(:source_file)

        get new_admin_source_file_redact_file_path(source_file)

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
            source_file = create(:source_file)

            sign_in admin
            post admin_source_file_redact_file_path(source_file), as: :json

            expect(response).to be_successful
          end
        end

        context "with redacted file" do
          it "returns http success" do
            admin = create(:admin)
            source_file = create(:source_file)
            redacted_file = fixture_file_upload("pixel1x1.jpg", "image/jpeg")

            sign_in admin
            post admin_source_file_redact_file_path(source_file), params: {
              format: :json,
              redacted_file: redacted_file
            }

            source_file.reload

            expect(response).to be_successful
            expect(source_file.redacted_source_file).to be_attached
          end
        end

        context "without occupation standard" do
          it "only updates redacted_source_file" do
            admin = create(:admin)
            data_import = create(:data_import, occupation_standard: nil)
            source_file = create(:source_file, data_imports: [data_import])
            redacted_file = fixture_file_upload("pixel1x1.jpg", "image/jpeg")

            params = {
              format: :json,
              redacted_file: redacted_file
            }

            sign_in admin
            post admin_source_file_redact_file_path(source_file), params: params

            source_file.reload

            expect(response).to be_successful
            expect(source_file.redacted_source_file).to be_attached
          end
        end
      end
    end
  end
end
