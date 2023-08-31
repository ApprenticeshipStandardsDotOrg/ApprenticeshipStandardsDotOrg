require "rails_helper"

RSpec.describe "Admin::Organization", type: :request do
  describe "GET /index" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          create_pair(:organization)

          sign_in admin
          get admin_organizations_path

          expect(response).to be_successful
        end

        it "can search" do
          admin = create(:admin)

          sign_in admin
          get admin_organizations_path(search: "foo")

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)

          sign_in admin
          get admin_organizations_path

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          get admin_organizations_path

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        expect {
          get admin_organizations_path
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe "GET /show/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          organization = create(:organization)

          sign_in admin
          get admin_organization_path(organization)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)
          organization = create(:organization)

          sign_in admin
          get admin_organization_path(organization)

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          organization = create(:organization)

          get admin_organization_path(organization)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        organization = create(:organization)

        expect {
          get admin_organization_path(organization)
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe "GET /edit/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          organization = create(:organization)

          sign_in admin
          get edit_admin_organization_path(organization)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)
          organization = create(:organization)

          sign_in admin
          get edit_admin_organization_path(organization)

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          organization = create(:organization)

          get edit_admin_organization_path(organization)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        organization = create(:organization)

        expect {
          get edit_admin_organization_path(organization)
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe "PUT /update/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        context "with valid params" do
          it "updates record and redirects to show page" do
            admin = create(:admin)
            organization = create(:organization)

            sign_in admin
            patch admin_organization_path(organization),
              params: {
                organization: {
                  title: "New title"
                }
              }

            organization.reload
            expect(organization.title).to eq "New title"
            expect(response).to redirect_to admin_organization_path(organization)
          end
        end

        context "with invalid params" do
          it "redirects to index" do
            admin = create(:admin)
            organization = create(:organization)

            sign_in admin
            patch admin_organization_path(organization),
              params: {
                organization: {
                  title: ""
                }
              }

            organization.reload
            expect(organization.title).to_not be_blank
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end
  end
end
