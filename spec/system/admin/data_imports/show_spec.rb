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

  it "shows a legacy Data Import without an associated Import", :admin do
    admin = create(:admin)
    data_import = create(:data_import, import: nil)

    login_as admin
    visit admin_data_import_path(data_import)

    expect(page).to have_current_path(admin_data_import_path(data_import))
    expect(page).to have_content(data_import.file.filename.to_s)
    expect(page).to have_no_link("Edit #{data_import.file.filename}")
    expect(page).to have_no_button("Destroy")
  end
end
