require "rails_helper"

RSpec.describe "admin/data_imports/show" do
  it "has Edit Data Import button with correct link", :admin do
    admin = create(:admin)
    import = create(:imports_pdf)
    data_import = create(:data_import, import: import)

    login_as admin
    visit admin_data_import_path(data_import)

    expect(page).to have_link "Edit #{data_import.file.filename}", href: edit_admin_import_data_import_path(import, data_import)

    click_on "Edit #{data_import.file.filename}"
  end

  it "has Destroy Data Import button with correct link", :admin do
    admin = create(:admin)
    import = create(:imports_pdf)
    data_import = create(:data_import, import: import)

    login_as admin
    visit admin_data_import_path(data_import)

    expect(page).to have_selector "form[action='#{admin_import_data_import_path(import, data_import)}'][method='post']"
    expect(page).to have_button "Destroy"

    expect {
      click_on "Destroy"
    }.to change(DataImport, :count).by(-1)
  end
end
