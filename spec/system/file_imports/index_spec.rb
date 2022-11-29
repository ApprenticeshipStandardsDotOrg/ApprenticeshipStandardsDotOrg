require "rails_helper"

RSpec.describe "file_imports/index" do
  it "displays status and link to file", :admin do
    create :standards_import, :with_files
    admin = create :admin

    login_as admin
    visit file_imports_path

    expect(page).to have_content("Pending").once
    expect(page).to have_link("pixel1x1.jpg")
  end
end
