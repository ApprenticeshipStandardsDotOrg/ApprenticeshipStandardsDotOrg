require "rails_helper"

RSpec.describe "admin/source_files/edit" do
  it "allows admin user to edit file import", :admin do
    file = create :source_file
    admin = create :admin

    login_as admin
    visit admin_source_files_path

    within(:grid) do
      first("a", text: "Edit").click
    end

    expect(page).to have_content("Edit #{file.filename}")
    select("Completed", from: "source_file[status]").click
    click_on "Update Source file"
    within("h1") do
      expect(page).to have_content("Source Files")
    end
    expect(page).to have_content("Completed")
    file.reload
    expect(file.status).to eq "completed"
  end
end
