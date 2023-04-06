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
end
