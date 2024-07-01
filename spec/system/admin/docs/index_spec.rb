require "rails_helper"

RSpec.describe "admin/docs/index", :admin do
  context "when admin" do
    it "views docs" do
      admin = create(:admin)

      login_as admin
      visit admin_docs_path

      expect(page).to have_selector :heading, "Docs"
    end
  end

  context "when converter" do
    it "views docs" do
      converter = create(:user, :converter)

      login_as converter
      visit admin_docs_path

      expect(page).to have_selector :heading, "Docs"
    end
  end
end
