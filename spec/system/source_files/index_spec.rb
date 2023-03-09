require "rails_helper"

RSpec.describe "source_files/index" do
  it "displays status, link to file, and option to convert or edit", :admin do
    create(:standards_import, :with_files)
    admin = create :admin

    login_as admin
    visit source_files_path

    source_file = SourceFile.last
    expect(page).to have_content("Pending").once
    expect(page).to have_link("pixel1x1.jpg")
    expect(page).to have_link("Convert", href: new_source_file_data_import_path(source_file))
    expect(page).to have_link("Edit", href: edit_source_file_path(source_file))
  end

  it "convert link allows editing existing data import", :admin do
    data_import = create(:data_import)
    source_file = data_import.source_file
    admin = create :admin

    login_as admin
    visit source_files_path

    expect(page).to have_content("Pending").once
    expect(page).to have_link("Convert", href: edit_source_file_data_import_path(source_file, data_import))
    expect(page).to have_link("Edit", href: edit_source_file_path(source_file))
  end
end
