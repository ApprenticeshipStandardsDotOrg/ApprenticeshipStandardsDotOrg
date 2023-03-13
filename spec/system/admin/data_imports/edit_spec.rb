require "rails_helper"

RSpec.describe "data_imports/edit" do
  it "allows admin user to edit data import", :admin do
    create(:standards_import, :with_files)
    source_file = SourceFile.first
    data_import = create(:data_import, source_file: source_file)
    admin = create :admin

    login_as admin
    visit edit_admin_source_file_data_import_path(source_file, data_import)

    expect(page).to have_content("Edit #{data_import.file.filename}")
    fill_in "Description", with: "New desc"
    attach_file "File", "spec/fixtures/files/pixel1x1.pdf"
    check "This is the last import for pixel1x1.pdf. Change its status to Completed"

    expect(ProcessDataImportJob).to receive(:perform_later).with(data_import: kind_of(DataImport), last_file: true)

    click_on "Submit"

    within("h1") do
      expect(page).to have_content("Data Import")
    end
    expect(page).to have_content("Description")
    expect(page).to have_content("New desc")
    expect(page).to have_content("File")
    expect(page).to have_content("pixel1x1.pdf")
    expect(page).to have_content("Occupation standard")
    expect(page).to have_content(data_import.occupation_standard.title)
  end
end
