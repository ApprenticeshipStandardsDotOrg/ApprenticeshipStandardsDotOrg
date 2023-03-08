require "rails_helper"

RSpec.describe "data_imports/new" do
  it "allows admin user to create data import", :admin do
    source_file = create(:source_file)
    admin = create :admin

    login_as admin
    visit new_source_file_data_import_path(source_file)

    within("h1") do
      expect(page).to have_content("Upload Occupation Standards")
    end
    fill_in "Description", with: "Some desc"
    attach_file "File", "spec/fixtures/files/pixel1x1.pdf"

    click_on "Submit"

    within("h1") do
      expect(page).to have_content("Data Import")
    end
    expect(page).to have_content("Description")
    expect(page).to have_content("Some desc")
    expect(page).to have_content("File")
    expect(page).to have_content("pixel1x1.pdf")
    expect(page).to_not have_content("Occupation standard")
  end
end
