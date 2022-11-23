require "rails_helper"

RSpec.describe "user/sessions/new", :admin, :js do
  context "with valid parameters" do
    it "signs user in" do
      user = create(:admin)
      visit new_user_session_path

      fill_in "Email", with: user.email
      fill_in "Password", with: user.password

      click_on "Log in"
      expect(page).to have_link "Logout"

      click_on "Logout"
      expect(page).to have_field "Email"
    end
  end

  context "with invalid parameters" do
    it "shows error message" do
      visit new_user_session_path

      fill_in "Email", with: "user@example.com"
      fill_in "Password", with: "badpassword"

      click_on "Log in"
      expect(page).to_not have_link "Logout"
      expect(page).to have_text "Invalid Email or password"
      expect(page).to have_css('div[role="alert"]')
    end
  end
end
