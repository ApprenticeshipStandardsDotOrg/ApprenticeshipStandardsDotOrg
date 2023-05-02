require "rails_helper"

RSpec.describe "admin/data_imports/new" do
  it "allows admin user to create data import", :admin do
    create(:standards_import, :with_files)
    source_file = SourceFile.first
    admin = create :admin

    login_as admin
    visit new_admin_source_file_data_import_path(source_file)

    within("h1") do
      expect(page).to have_content("Import data for source file: pixel1x1.pdf")
    end
    expect(page).to have_link("import template", href: "https://www.notion.so/888b37991598495cb22d0dabc08ae3b2?v=f29055b156fa471ea9c30e9467238e66")
    expect(page).to have_link("ApprenticeshipStandards Notion", href: "https://www.notion.so/Instructions-060de1705e7d471fa8bee7a7c535a2d6")

    fill_in "Description", with: "Some desc"
    attach_file "File", file_fixture("comp-occupation-standards-template.xlsx")

    expect(ProcessDataImportJob).to receive(:perform_later).with(data_import: kind_of(DataImport), last_file: false)

    click_on "Submit"

    within("h1") do
      expect(page).to have_content("Data Import")
    end
    expect(page).to have_content("Description")
    expect(page).to have_content("Some desc")
    expect(page).to have_content("File")
    expect(page).to have_content("comp-occupation-standards-template.xlsx")
  end

  it "does not allow invalid file types", :admin do
    create(:standards_import, :with_files)
    source_file = SourceFile.first
    admin = create :admin

    login_as admin
    visit new_admin_source_file_data_import_path(source_file)

    attach_file "File", file_fixture("pixel1x1.jpg")

    expect(ProcessDataImportJob).to_not receive(:perform_later)

    click_on "Submit"

    expect(page).to have_content "File with these extensions only are accepted"
  end

  it "allows admin user to process file with last_file flag", :admin do
    create(:standards_import, :with_files)
    source_file = SourceFile.first
    admin = create :admin

    login_as admin
    visit new_admin_source_file_data_import_path(source_file)

    within("h1") do
      expect(page).to have_content("Import data for source file: pixel1x1.pdf")
    end
    expect(page).to have_link("import template", href: "https://www.notion.so/888b37991598495cb22d0dabc08ae3b2?v=f29055b156fa471ea9c30e9467238e66")
    expect(page).to have_link("ApprenticeshipStandards Notion", href: "https://www.notion.so/Instructions-060de1705e7d471fa8bee7a7c535a2d6")

    fill_in "Description", with: "Some desc"
    attach_file "File", file_fixture("comp-occupation-standards-template.xlsx")
    check "This is the last import for pixel1x1.pdf. Change its status to Completed"

    expect(ProcessDataImportJob).to receive(:perform_later).with(data_import: kind_of(DataImport), last_file: true)

    click_on "Submit"

    within("h1") do
      expect(page).to have_content("Data Import")
    end
    expect(page).to have_content("Description")
    expect(page).to have_content("Some desc")
    expect(page).to have_content("File")
    expect(page).to have_content("comp-occupation-standards-template.xlsx")
  end
end
