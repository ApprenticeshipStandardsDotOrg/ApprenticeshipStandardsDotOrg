require "rails_helper"

RSpec.describe "admin/source_files/index", :admin do
  it "displays status, link to file, and option to convert or edit" do
    create(:standards_import, :with_files)
    admin = create :admin

    login_as admin
    visit admin_source_files_path

    source_file = SourceFile.last
    expect(page).to have_content("Pending").once
    expect(page).to have_link("pixel1x1.pdf")
    expect(page).to have_link("Convert", href: new_admin_source_file_data_import_path(source_file))
    expect(page).to have_link("Edit", href: edit_admin_source_file_path(source_file))
    expect(page).to have_link("New source file", href: new_standards_import_path)
  end

  it "can search on filename" do
    create(:standards_import, :with_files)
    source_file = SourceFile.last
    admin = create :admin

    login_as admin
    visit admin_source_files_path(search: "pixel")

    expect(page).to have_content("Pending").once
    expect(page).to have_link("pixel1x1.pdf")
    expect(page).to have_link("Convert", href: new_admin_source_file_data_import_path(source_file))
    expect(page).to have_link("Edit", href: edit_admin_source_file_path(source_file))
    expect(page).to have_link("New source file", href: new_standards_import_path)

    visit admin_source_files_path(search: "foobar")

    expect(page).to_not have_content("Pending").once
    expect(page).to_not have_link("pixel1x1.pdf")
    expect(page).to_not have_link("Convert", href: admin_source_file_path(source_file))
    expect(page).to_not have_link("Edit", href: edit_admin_source_file_path(source_file))
  end
end
