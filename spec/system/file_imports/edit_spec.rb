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

    expect(page).to have_content("Edit #{file.active_storage_attachment.blob.filename}")
    select("Processing", from: "file_import[status]").click
    click_on "Update"
    expect(page).to have_content("File Imports")
    file.reload
    expect(file.status).to eq "processing"
  end
end
