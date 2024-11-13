require "rails_helper"

RSpec.describe "Admin::User", type: :request do
  describe "GET /index" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          create_pair(:user)
          create_pair(:api_key, user: User.first)

          sign_in admin
          get admin_users_path

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)

          sign_in admin
          get admin_users_path

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          get admin_users_path

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        get admin_users_path

        expect(response).to be_not_found
      end
    end
  end

  describe "POST /create", :admin do
    it "creates the user without password" do
      admin = create(:admin)
      params = {
        user: {
          name: "Test #1",
          email: "test@test.com",
          role: :admin
        }
      }

      sign_in admin
      expect {
        post admin_users_path, params: params
      }.to change(User, :count).by(1)
    end

    it "sends invitation email" do
      admin = create(:admin)
      params = {
        user: {
          name: "Test #1",
          email: "test@test.com",
          role: :admin
        }
      }

      sign_in admin
      post admin_users_path, params: params

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq "Invitation instructions"
      expect(email.to).to eq ["test@test.com"]
      expect(email.from).to eq ["no-reply@apprenticeshipstandards.org"]
    end
  end

  describe "POST /invite", :admin do
    it "sends invitation email" do
      admin = create(:admin)
      user = create(:user)

      sign_in admin
      post invite_admin_user_path(id: user.id)

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq "Invitation instructions"
      expect(email.to).to eq [user.email]
      expect(email.from).to eq ["no-reply@apprenticeshipstandards.org"]
    end

    it "redirects to user path" do
      admin = create(:admin)
      user = create(:user)

      sign_in admin
      post invite_admin_user_path(id: user.id)

      expect(response).to redirect_to admin_user_path(user)
    end

    it "renders flash notice on success" do
      admin = create(:admin)
      user = create(:user)

      sign_in admin
      post invite_admin_user_path(id: user.id)

      expect(flash[:notice]).to eq I18n.t("devise.invitations.send_instructions", email: user.email)
    end

    it "renders flash error on failure" do
      admin = create(:admin)
      user = create(:user)

      allow_any_instance_of(User).to receive(:invite!).and_return(double(errors: ["error"]))

      sign_in admin
      post invite_admin_user_path(id: user.id)

      expect(flash[:error]).to eq "There was an error trying to send an invite to this user"
    end
  end
end
