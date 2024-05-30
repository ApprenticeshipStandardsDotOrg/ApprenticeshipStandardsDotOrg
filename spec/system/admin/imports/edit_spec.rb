require "rails_helper"

RSpec.describe "admin/imports/edit", :admin do
  context "when Imports::Pdf" do
    context "when admin" do
      it "can update the status" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin)
        import = create(:imports_pdf, status: :pending)

        login_as admin
        visit edit_admin_import_path(import)

        select "archived"
        click_on "Update Pdf"

        expect(page).to have_text "archived"
        expect(import.reload).to be_archived

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end
  end

  context "when Imports::Uncategorized" do
    context "when admin" do
      it "can update the status" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin)
        import = create(:imports_uncategorized, status: :unfurled)

        login_as admin
        visit edit_admin_import_path(import)

        select "archived"
        click_on "Update Uncategorized"

        expect(page).to have_text "archived"
        expect(import.reload).to be_archived

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end
  end
end
