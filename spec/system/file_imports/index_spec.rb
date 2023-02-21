require "rails_helper"

RSpec.describe "file_imports/index" do
  it "displays status, link to file, and option to convert or edit", :admin do
    create(:standards_import, :with_files)
    admin = create :admin

    login_as admin
    visit file_imports_path

    file_import = FileImport.last
    expect(page).to have_content("Pending").once
    expect(page).to have_link("pixel1x1.jpg")
    expect(page).to have_link("Convert", href: new_file_import_data_import_path(file_import))
    expect(page).to have_link("Edit", href: edit_file_import_path(file_import))
  end

  it "convert link allows editing existing data import", :admin do
    data_import = create(:data_import)
    file_import = data_import.file_import
    admin = create :admin

    login_as admin
    visit file_imports_path

    expect(page).to have_content("Pending").once
    expect(page).to have_link("Convert", href: edit_file_import_data_import_path(file_import, data_import))
    expect(page).to have_link("Edit", href: edit_file_import_path(file_import))
  end
end
