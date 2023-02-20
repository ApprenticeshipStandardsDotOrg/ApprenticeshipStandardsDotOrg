require "rails_helper"

RSpec.describe "file_imports/index" do
  it "displays status and link to file", :admin do
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
end
