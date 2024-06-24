require "rails_helper"

RSpec.describe "admin/data_imports/show" do
  context "with import feature flag" do 
    it "has Edit Data Import button with correct link", :admin, :js do
      stub_feature_flag(:show_imports_in_administrate, true)

      admin = create(:admin)
      import = create(:imports_pdf)
      data_import = create(:data_import, import: import, source_file: nil)

      login_as admin
      visit admin_data_import_path(data_import)

      expect(page).to have_link "Edit #{data_import.file.filename}", href: edit_admin_data_import_path(data_import)

      click_on "Edit #{data_import.file.filename}"

      expect(page).to have_text "The file imported on this screen should be based on"
    end
  end
end
