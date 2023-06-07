require "rails_helper"

RSpec.describe "admin/users/show" do
  it "can create an api token", :admin do
    admin = create(:admin)
    user = create(:user)

    login_as admin
    visit admin_user_path(user)

    expect {
      click_on "Create API key"
    }.to change(APIKey, :count).by(1)

    expect(page).to have_text "API key was successfully created."
    api_key = APIKey.last
    expect(api_key.user).to eq user
  end

  it "can resend an invite to user", :admin do
    admin = create(:admin)
    user = create(:user)

    user.invite!

    login_as admin
    visit admin_user_path(user)

    click_on "Send Set Password email"

    expect(page).to have_text "An invitation email has been sent to #{user.email}."
  end

  it "cannot resend invite to users what were not invited previously", :admin do
    admin = create(:admin)
    user = create(:user)

    login_as admin
    visit admin_user_path(user)

    expect(page).to_not have_button "Send Set Password email"
  end

  it "cannot resend invite to users what already accepted invitation", :admin do
    admin = create(:admin)
    user = create(:user)

    user.invite!
    user.accept_invitation!

    login_as admin
    visit admin_user_path(user)

    expect(page).to_not have_button "Send Set Password email"
  end
end
