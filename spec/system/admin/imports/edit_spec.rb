require "rails_helper"

RSpec.describe "admin/imports/edit", :admin do
  context "when Imports::Pdf" do
    context "when admin" do
      it "can update the status" do
        admin = create(:admin)
        import = create(:imports_pdf, status: :pending)

        login_as admin
        visit edit_admin_import_path(import)

        expect(page).to have_field "File"

        select "archived"
        click_on "Update Pdf"

        expect(page).to have_text "archived"
        expect(import.reload).to be_archived
      end
    end
  end

  context "when Imports::Uncategorized" do
    context "when admin" do
      it "can update the status" do
        admin = create(:admin)
        import = create(:imports_uncategorized, status: :unfurled)

        login_as admin
        visit edit_admin_import_path(import)

        expect(page).to have_field "File"

        select "archived"
        click_on "Update Uncategorized"

        expect(page).to have_text "archived"
        expect(import.reload).to be_archived
      end
    end
  end

  context "when Imports::DocxListing" do
    context "when admin" do
      it "can update the status" do
        admin = create(:admin)
        import = create(:imports_docx_listing, status: :unfurled)

        login_as admin
        visit edit_admin_import_path(import)

        expect(page).to have_field "File"

        select "archived"
        click_on "Update Docx listing"

        expect(page).to have_text "archived"
        expect(import.reload).to be_archived
      end
    end
  end

  context "when Imports::Docx" do
    context "when admin" do
      it "can update the status" do
        admin = create(:admin)
        import = create(:imports_docx, status: :unfurled)

        login_as admin
        visit edit_admin_import_path(import)

        expect(page).to have_field "File"

        select "archived"
        click_on "Update Docx"

        expect(page).to have_text "archived"
        expect(import.reload).to be_archived
      end
    end
  end

  context "when Imports::Doc" do
    context "when admin" do
      it "can update the status" do
        admin = create(:admin)
        import = create(:imports_doc, status: :unfurled)

        login_as admin
        visit edit_admin_import_path(import)

        expect(page).to have_field "File"

        select "archived"
        click_on "Update Doc"

        expect(page).to have_text "archived"
        expect(import.reload).to be_archived
      end
    end
  end
end
