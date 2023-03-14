require "rails_helper"

RSpec.describe "admin/source_files/edit" do
  it "allows admin user to edit file import", :admin do
    file = create :source_file
    admin = create :admin

    login_as admin
    visit admin_source_files_path

    within("div#file-imports") do
      first("a", text: "Edit").click
    end

    expect(page).to have_content("Edit #{file.filename}")
    select("Processing", from: "source_file[status]").click
    click_on "Update"
    within("h1") do
      expect(page).to have_content("Source files")
    end
    expect(page).to have_content("Processing")
    file.reload
    expect(file.status).to eq "processing"
  end
end
