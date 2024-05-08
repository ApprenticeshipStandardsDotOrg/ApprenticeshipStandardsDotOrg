require "rails_helper"

RSpec.describe "admin/imports/index" do
  context "when admin" do
    it "views Imports of all types", :admin do
      stub_feature_flag(:show_imports_in_administrate, true)

      admin = create(:admin)
      create(:imports_uncategorized, status: :pending)
      create(:imports_docx_listing, status: :completed)
      create(:imports_pdf, status: :needs_support)

      login_as admin
      visit admin_imports_path

      expect(page).to have_text "Imports::Uncategorized"
      expect(page).to have_text "Imports::DocxListing"
      expect(page).to have_text "Imports::Pdf"

      expect(page).to have_text "pending"
      expect(page).to have_text "completed"
      expect(page).to have_text "needs_support"

      click_on "Imports::Uncategorized", match: :first
      expect(page).to have_text "StandardsImport" # parent

      stub_feature_flag(:show_imports_in_administrate, false)
    end

    it "shows Convert link on Imports::Pdf", :admin do
      stub_feature_flag(:show_imports_in_administrate, true)

      admin = create(:admin)
      docx = create(:imports_docx_listing)
      pdf = create(:imports_pdf)

      login_as admin
      visit admin_imports_path

      expect(page).to have_link("Convert", href: new_admin_import_data_import_path(pdf))
      expect(page).to_not have_link("Convert", href: new_admin_import_data_import_path(docx))

      click_on "Convert"

      expect(page).to have_text "The file imported on this screen"

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

      click_on "Imports::Pdf", match: :first
      expect(page).to have_text "Imports::Uncategorized" # parent

      stub_feature_flag(:show_imports_in_administrate, false)
    end
  end
end
