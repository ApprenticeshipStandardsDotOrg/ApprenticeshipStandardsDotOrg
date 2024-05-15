require "rails_helper"

RSpec.describe "admin/imports/show", :admin do
  context "when Imports::Pdf" do
    context "when admin" do
      it "does not have button for needing support but has data import and redact buttons" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin)
        import = create(:imports_pdf)

        login_as admin
        visit admin_import_path(import)

        expect(page).to have_text "Imports::Pdf"
        expect(page).to_not have_button "Needs support"
        expect(page).to have_link "New data import", href: new_admin_import_data_import_path(import)
        expect(page).to have_link "Redact document", href: new_admin_import_redact_file_path(import)
        expect(page).to have_link "Edit", href: edit_admin_import_path(import)
        expect(page).to_not have_link "Destroy"

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end

    context "when converter" do
      it "has button for needing support, data imports, and redact buttons" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin, :converter)
        import = create(:imports_pdf)

        login_as admin
        visit admin_import_path(import)

        expect(page).to have_text "Imports::Pdf"
        expect(page).to have_button "Needs support"
        expect(page).to have_link "New data import", href: new_admin_import_data_import_path(import)
        expect(page).to have_link "Redact document", href: new_admin_import_redact_file_path(import)
        expect(page).to_not have_link "Edit", href: edit_admin_import_path(import)
        expect(page).to_not have_link "Destroy"

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end
  end

  context "when not Imports::Pdf type" do
    context "when admin" do
      it "does not have buttons for needing support, data import or redact" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin)
        import = create(:imports_uncategorized)

        login_as admin
        visit admin_import_path(import)

        expect(page).to have_text "Imports::Uncategorized"
        expect(page).to_not have_button "Needs support"
        expect(page).to_not have_link "New data import"
        expect(page).to_not have_link "Redact document"
        expect(page).to have_link "Edit", href: edit_admin_import_path(import)
        expect(page).to_not have_link "Destroy"

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end
  end
end
