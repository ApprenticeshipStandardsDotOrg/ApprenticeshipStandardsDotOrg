require "rails_helper"

RSpec.describe "source_files/show" do
  it "displays existing data imports and button to upload another", :admin do
    admin = create(:admin)
    source_file = create(:source_file)

    occupation_standard1 = create(:occupation_standard, title: "Mechanic")
    data_import1 = create(:data_import, source_file: source_file, occupation_standard: occupation_standard1)

    occupation_standard2 = create(:occupation_standard, title: "Pipe Fitter")
    data_import2 = create(:data_import, :hybrid, source_file: source_file, occupation_standard: occupation_standard2)

    login_as admin
    visit source_file_path(source_file)

    expect(page).to have_content "Source file: #{source_file.filename}" 

    expect(page).to have_link "Edit", href: edit_source_file_data_import_path(source_file, data_import1)
    expect(page).to have_link "occupation-standards-template.xlsx", href: source_file_data_import_path(source_file, data_import1)
    expect(page).to have_link "Mechanic", href: occupation_standard_path(occupation_standard1)

    expect(page).to have_link "Edit", href: edit_source_file_data_import_path(source_file, data_import2)
    expect(page).to have_link "comp-occupation-standards-template.xlsx", href: source_file_data_import_path(source_file, data_import2)
    expect(page).to have_link "Pipe Fitter", href: occupation_standard_path(occupation_standard2)

    expect(page).to have_link "New data import", href: new_source_file_data_import_path(source_file)
  end
end
