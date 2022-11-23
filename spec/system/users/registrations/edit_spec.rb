require "rails_helper"

RSpec.describe "user/registrations/edit", :admin, :js do
  context "with valid parameters" do
    it "updates user" do
      user = create(:admin)

      login_as user
      visit edit_user_registration_path

      fill_in "Email", with: "newemail@example.com"
      fill_in "Password", with: "brandnewpassword"
      fill_in "Password confirmation", with: "brandnewpassword"
      fill_in "Current password", with: user.password

      click_on "Update"
      expect(page).to have_text "updated successfully"

      user.reload
      expect(user.email).to eq "newemail@example.com"
      expect(user.valid_password?("brandnewpassword")).to be true
    end
  end

  context "with invalid parameters" do
    it "shows error message" do
      user = create(:admin)

      login_as user
      visit edit_user_registration_path

      fill_in "Email", with: "newemail@example.com"
      fill_in "Password", with: "brandnewpassword"
      fill_in "Password confirmation", with: "brandnewpassword"
      fill_in "Current password", with: "badcurrentpassword"

      click_on "Update"
      expect(page).to have_text "Current password is invalid"
      expect(page).to have_field "Email", with: "newemail@example.com"
    end
  end
end
