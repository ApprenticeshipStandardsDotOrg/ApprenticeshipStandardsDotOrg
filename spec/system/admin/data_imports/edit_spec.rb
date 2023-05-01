require "rails_helper"

RSpec.describe "admin/data_imports/edit" do
  it "allows admin user to edit data import", :admin do
    create(:standards_import, :with_files)
    source_file = SourceFile.first
    data_import = create(:data_import, source_file: source_file)
    admin = create :admin

    login_as admin
    visit edit_admin_source_file_data_import_path(source_file, data_import)

    expect(page).to have_content("Edit Data Import for #{data_import.file.filename}")
    fill_in "Description", with: "New desc"
    attach_file "File", file_fixture("comp-occupation-standards-template.xlsx")
    check "This is the last import for pixel1x1.pdf. Change its status to Completed"

    expect(ProcessDataImportJob).to receive(:perform_later).with(data_import: kind_of(DataImport), last_file: true)

    click_on "Submit"

    within("h1") do
      expect(page).to have_content("Show Data Import")
    end
    expect(page).to have_content("Description")
    expect(page).to have_content("New desc")
    expect(page).to have_content("File")
    expect(page).to have_content("comp-occupation-standards-template.xlsx")
    expect(page).to have_content("Occupation standard")
    expect(page).to have_content(data_import.occupation_standard.title)
  end
end
