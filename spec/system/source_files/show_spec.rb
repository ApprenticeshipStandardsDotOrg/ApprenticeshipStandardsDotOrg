require "rails_helper"

RSpec.describe "source_files/show" do
  it "displays existing data imports and button to upload another", :admin do
    source_file = create(:source_file)
    data_import1 = create(:data_import, source_file: source_file)
    data_import2 = create(:data_import, :hybrid, source_file: source_file)
    admin = create(:admin)

    login_as admin
    visit source_file_path(source_file)

    expect(page).to have_content "Source file: #{source_file.filename}" 
    expect(page).to have_link "occupation-standards-template.xlsx", href: source_file_data_import_path(source_file, data_import1)
    expect(page).to have_link "comp-occupation-standards-template.xlsx", href: source_file_data_import_path(source_file, data_import2)
  end
end
