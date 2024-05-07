require "rails_helper"

RSpec.describe "admin/imports/index" do
  context "when admin" do
    it "views Imports of all types", :admin do
      stub_feature_flag(:show_imports_in_administrate, true)

      admin = create(:admin)
      create(:imports_uncategorized)
      create(:imports_docx_listing)
      create(:imports_pdf)

      login_as admin
      visit admin_imports_path

      expect(page).to have_text "Imports::Uncategorized"
      expect(page).to have_text "Imports::DocxListing"
      expect(page).to have_text "Imports::Pdf"

      stub_feature_flag(:show_imports_in_administrate, false)
    end
  end

  context "when converter" do
    it "views Imports of Pdf type only", :admin do
      stub_feature_flag(:show_imports_in_administrate, true)

      admin = create(:admin, :converter)
      create(:imports_uncategorized)
      create(:imports_docx_listing)
      create(:imports_pdf)

      login_as admin
      visit admin_imports_path

      expect(page).to_not have_text "Imports::Uncategorized"
      expect(page).to_not have_text "Imports::DocxListing"
      expect(page).to have_text "Imports::Pdf"

      stub_feature_flag(:show_imports_in_administrate, false)
    end
  end
end
