require "rails_helper"

RSpec.describe "admin/imports/index", :admin do
  context "when admin" do
    it "views Imports of all types" do
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
    end

    it "shows Convert link on Imports::Pdf" do
      admin = create(:admin)
      docx = create(:imports_docx_listing)
      pdf = create(:imports_pdf)

      login_as admin
      visit admin_imports_path

      expect(page).to have_link("Convert", href: new_admin_import_data_import_path(pdf))
      expect(page).to_not have_link("Convert", href: new_admin_import_data_import_path(docx))

      click_on "Convert"

      expect(page).to have_text "The file imported on this screen"
    end

    it "can claim an import", js: true do
      converter = create(:user, :converter, name: "Mickey Mouse")
      create(:imports_pdf)
      create(:imports_pdf, assignee: converter)
      admin = create(:admin, name: "Amy Applebaum")

      login_as admin
      visit admin_imports_path

      expect(page).to have_text "Mickey Mouse"
      expect(page).to have_button("Claim").once

      click_button "Claim"

      expect(page).to have_text "Amy Applebaum"
      expect(page).to_not have_button "Claim"
    end

    it "allows filtering by redaction status" do
      admin = create(:admin)
      create(:imports_uncategorized)
      create(:imports_pdf, :with_redacted_pdf, status: :pending)
      create(:imports_pdf, status: :completed, public_document: false)
      create(:imports_pdf, status: :needs_backend_support, public_document: true)

      login_as admin
      visit admin_imports_path

      expect(page).to have_content("Imports::Uncategorized")
      expect(page).to have_content("Imports::Pdf").thrice

      expect(page).to have_button "Filter by:"
      click_on "Filter by"
      click_on "Needs Redaction"

      expect(page).to have_text "completed"
      expect(page).to_not have_text "pending"
      expect(page).to_not have_text "needs_backend_support"
      expect(page).to_not have_content("Imports::Uncategorized")
      expect(page).to have_content("Imports::Pdf").once

      click_on "Filter by"
      click_on "Redacted"

      expect(page).to_not have_text "completed"
      expect(page).to have_text "pending"
      expect(page).to_not have_text "needs_backend_support"
      expect(page).to_not have_content("Imports::Uncategorized")
      expect(page).to have_content("Imports::Pdf").once

      click_on "Filter by"
      click_on "Show All"

      expect(page).to have_text "completed"
      expect(page).to have_text "pending"
      expect(page).to have_text "needs_backend_support"
      expect(page).to have_content("Imports::Uncategorized")
      expect(page).to have_content("Imports::Pdf").thrice
    end

    it "can delete import" do
      admin = create(:admin)
      uncat = create(:imports_uncategorized, status: "unfurled")
      create(:imports_pdf, parent: uncat, status: "pending", created_at: 1.day.ago) # inaccurately set the created_at date so we can easily Destroy the uncat record by matching on the first record

      login_as admin
      visit admin_imports_path

      expect(page).to have_text "unfurled"
      expect(page).to have_text "pending"

      expect {
        click_on "Destroy", match: :first
      }.to change(Import, :count).by(-2)

      expect(page).to_not have_text "unfurled"
    end
  end

  context "when converter" do
    it "views Imports of Pdf type only" do
      admin = create(:admin, :converter)
      create(:imports_uncategorized)
      create(:imports_docx_listing)
      pdf = create(:imports_pdf, status: :completed)

      login_as admin
      visit admin_imports_path

      expect(page).to_not have_text "Imports::Uncategorized"
      expect(page).to_not have_text "Imports::DocxListing"
      expect(page).to have_text "Imports::Pdf"

      expect(page).to_not have_link "Edit", href: edit_admin_import_path(pdf)
      expect(page).to_not have_text "Destroy"

      click_on "Imports::Pdf", match: :first
      expect(page).to have_text "completed"
    end

    it "does not allow user to claim archived files" do
      admin = create(:admin, :converter)
      create(:imports_pdf, status: :archived)

      login_as admin
      visit admin_imports_path

      expect(page).to_not have_button "Claim"
    end

    it "allows filtering by redaction status" do
      admin = create(:admin, :converter)
      create(:imports_pdf, :with_redacted_pdf, status: :pending)
      create(:imports_pdf, status: :completed)
      create(:imports_pdf, status: :needs_backend_support, public_document: true)

      login_as admin
      visit admin_imports_path

      expect(page).to have_button "Filter by:"
      click_on "Filter by"
      click_on "Needs Redaction"

      expect(page).to have_text "completed"
      expect(page).to_not have_text "pending"
      expect(page).to_not have_text "needs_backend_support"

      click_on "Filter by"
      click_on "Redacted"

      expect(page).to_not have_text "completed"
      expect(page).to have_text "pending"
      expect(page).to_not have_text "needs_backend_support"

      click_on "Filter by"
      click_on "Show All"

      expect(page).to have_text "completed"
      expect(page).to have_text "pending"
      expect(page).to have_text "needs_backend_support"
    end

    it "can claim an import" do
      import = create(:imports_pdf, status: :pending)
      admin = create(:user, :converter, name: "Amy Applebaum")

      login_as admin
      visit admin_imports_path

      expect(page).to have_button("Claim").once

      click_button "Claim"

      expect(page).to have_text "Amy Applebaum"
      expect(page).to_not have_button "Claim"
      expect(import.reload.assignee).to eq admin
    end

    it "shows AI label when an import was used to do a conversion using AI" do
      open_ai_import = create(:open_ai_import, :with_pdf_import)
      open_ai_import.import

      admin = create(:admin)

      login_as admin
      visit admin_imports_path

      expect(page).to have_text("AI Converted")
    end
  end
end
