require "rails_helper"

RSpec.describe "file_imports/edit" do
  it "allows admin user to edit file import", :admin do
    file = create :file_import
    admin = create :admin

    login_as admin
    visit file_imports_path

    within("div#file-imports") do
      first("a", text: "Edit").click
    end

    expect(page).to have_content("Edit #{file.filename}")
    select("Processing", from: "file_import[status]").click
    click_on "Update"
    within("h1") do
      expect(page).to have_content("File Imports")
    end
    expect(page).to have_content("Processing")
    file.reload
    expect(file.status).to eq "processing"
  end
end
