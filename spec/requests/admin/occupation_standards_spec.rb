require "rails_helper"

RSpec.describe "Admin::OccupationStandard", type: :request do
  describe "GET /index" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          create_pair(:occupation_standard)

          sign_in admin
          get admin_occupation_standards_path

          expect(response).to be_successful
        end

        it "can search" do
          admin = create(:admin)

          sign_in admin
          get admin_occupation_standards_path(search: "foo")

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)

          sign_in admin
          get admin_occupation_standards_path

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          get admin_occupation_standards_path

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        get admin_occupation_standards_path

        expect(response).to be_not_found
      end
    end
  end

  describe "GET /show/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          data_import = create(:data_import)
          occupation_standard = data_import.occupation_standard

          sign_in admin
          get admin_occupation_standard_path(occupation_standard)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)
          data_import = create(:data_import)
          occupation_standard = data_import.occupation_standard

          sign_in admin
          get admin_occupation_standard_path(occupation_standard)

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          occupation_standard = create(:occupation_standard)

          get admin_occupation_standard_path(occupation_standard)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        occupation_standard = create(:occupation_standard)

        get admin_occupation_standard_path(occupation_standard)

        expect(response).to be_not_found
      end
    end
  end

  describe "GET /edit/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          data_import = create(:data_import)
          occupation_standard = data_import.occupation_standard

          sign_in admin
          get edit_admin_occupation_standard_path(occupation_standard)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)
          data_import = create(:data_import)
          occupation_standard = data_import.occupation_standard

          sign_in admin
          get edit_admin_occupation_standard_path(occupation_standard)

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          occupation_standard = create(:occupation_standard)

          get edit_admin_occupation_standard_path(occupation_standard)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        occupation_standard = create(:occupation_standard)

        get edit_admin_occupation_standard_path(occupation_standard)

        expect(response).to be_not_found
      end
    end
  end

  describe "PUT /update/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        context "with valid params" do
          it "updates record and redirects to show page" do
            admin = create(:admin)
            occupation_standard = create(:occupation_standard, occupation: nil)

            sign_in admin
            patch admin_occupation_standard_path(occupation_standard),
              params: {
                occupation_standard: {
                  title: "New title",
                  onet_code: "123.45",
                  rapids_code: "98765",
                  status: "published"
                }
              }

            occupation_standard.reload
            expect(occupation_standard.title).to eq "New title"
            expect(occupation_standard.onet_code).to eq "123.45"
            expect(occupation_standard.rapids_code).to eq "98765"
            expect(occupation_standard).to be_published
            expect(response).to redirect_to admin_occupation_standard_path(occupation_standard)
          end
        end

        context "with invalid params" do
          it "updates record and redirects to index" do
            admin = create(:admin)
            occupation_standard = create(:occupation_standard, occupation: nil)
            create(:data_import, occupation_standard: occupation_standard)

            sign_in admin
            patch admin_occupation_standard_path(occupation_standard),
              params: {
                occupation_standard: {
                  title: "",
                  onet_code: "123.45",
                  rapids_code: "98765",
                  status: "published"
                }
              }

            occupation_standard.reload
            expect(occupation_standard.title).to_not be_blank
            expect(occupation_standard.onet_code).to_not eq "123.45"
            expect(occupation_standard.rapids_code).to_not eq "98765"
            expect(occupation_standard).to be_importing
            expect(response).to have_http_status(:unprocessable_content)
          end
        end
      end
    end
  end

  describe "POST /create" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "creates record with associations and redirects to show page" do
          admin = create(:admin)
          import = create(:imports_pdf)

          registration_agency = create(:registration_agency)
          occupation_standard_attributes = attributes_for(:occupation_standard).tap do |attrs|
            attrs[:registration_agency_id] = registration_agency.id
            attrs[:import_id] = import.id
            attrs[:open_ai_response] = "{}"
          end

          sign_in admin
          post admin_occupation_standards_path,
            params: {
              occupation_standard: occupation_standard_attributes.except(:url)
            }

          occupation_standard = OccupationStandard.last

          expect(response).to redirect_to admin_occupation_standard_path(occupation_standard)
          expect(occupation_standard.open_ai_import).to_not be_nil
          expect(occupation_standard).to be_published

          open_ai_import = occupation_standard.open_ai_import

          expect(open_ai_import.response).to eq "{}"
          expect(open_ai_import.import_id).to eq import.id
          expect(import.reload).to be_archived
        end
      end
    end
  end
end
