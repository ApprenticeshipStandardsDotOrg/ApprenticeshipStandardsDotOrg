require "rails_helper"

RSpec.describe "Admin::Occupation", type: :request do
  describe "GET /index" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          create_pair(:occupation)

          sign_in admin
          get admin_occupations_path

          expect(response).to be_successful
        end

        it "can search" do
          admin = create(:admin)

          sign_in admin
          get admin_occupations_path(search: "foo")

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)

          sign_in admin
          get admin_occupations_path

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          get admin_occupations_path

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        get admin_occupations_path

        expect(response).to be_not_found
      end
    end
  end

  describe "GET /show/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          occupation = create(:occupation)

          sign_in admin
          get admin_occupation_path(occupation)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)
          occupation = create(:occupation)

          sign_in admin
          get admin_occupation_path(occupation)

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          occupation = create(:occupation)

          get admin_occupation_path(occupation)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        occupation = create(:occupation)

        get admin_occupation_path(occupation)

        expect(response).to be_not_found
      end
    end
  end

  describe "GET /edit/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          occupation = create(:occupation)

          sign_in admin
          get edit_admin_occupation_path(occupation)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)
          occupation = create(:occupation)

          sign_in admin
          get edit_admin_occupation_path(occupation)

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          occupation = create(:occupation)

          get edit_admin_occupation_path(occupation)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        occupation = create(:occupation)

        get edit_admin_occupation_path(occupation)

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
            occupation = create(:occupation)

            sign_in admin
            patch admin_occupation_path(occupation),
              params: {
                occupation: {
                  title: "New title"
                }
              }

            occupation.reload
            expect(occupation.title).to eq "New title"
            expect(response).to redirect_to admin_occupation_path(occupation)
          end
        end

        context "with invalid params" do
          it "redirects to index" do
            admin = create(:admin)
            occupation = create(:occupation)

            sign_in admin
            patch admin_occupation_path(occupation),
              params: {
                occupation: {
                  title: ""
                }
              }

            occupation.reload
            expect(occupation.title).to_not be_blank
            expect(response).to have_http_status(:unprocessable_content)
          end
        end
      end
    end
  end
end
