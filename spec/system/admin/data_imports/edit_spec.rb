require "rails_helper"

RSpec.describe "admin/data_imports/edit" do
  it "allows admin user to edit data import", :admin do
    pdf = create(:imports_pdf)
    data_import = create(:data_import, import: pdf, source_file: nil)
    admin = create(:admin)

    login_as admin
    visit edit_admin_import_data_import_path(pdf, data_import)

    expect(page).to have_content("Edit #{data_import.file.filename}")
    fill_in "Description", with: "New desc"
    attach_file "File", file_fixture("comp-occupation-standards-template.xlsx")
    check "Last file"

    expect(ProcessDataImportJob).to receive(:perform_later).with(data_import: kind_of(DataImport), last_file: true)

    click_on "Submit"

    within("h1") do
      expect(page).to have_content("Show comp-occupation")
    end
    expect(page).to have_content("Description")
    expect(page).to have_content("New desc")
    expect(page).to have_content("File")
    expect(page).to have_content("comp-occupation-standards-template.xlsx")
    expect(page).to have_content("Occupation standard")
    expect(page).to have_content(data_import.occupation_standard.title)
  end

  it "does not allow invalid file types", :admin do
    pdf = create(:imports_pdf)
    data_import = create(:data_import, source_file: nil, import: pdf)
    admin = create(:admin)

    login_as admin
    visit edit_admin_import_data_import_path(pdf, data_import)

    attach_file "File", file_fixture("pixel1x1.jpg")

    expect(ProcessDataImportJob).to_not receive(:perform_later)

    click_on "Submit"

    expect(page).to have_content "File with these extensions only are accepted"
  end
end
