require "rails_helper"

RSpec.describe "file_imports/edit" do
  it "displays edit link", :admin do
    create :file_import
    admin = create :admin

    login_as admin
    visit file_imports_path

    expect(page).to have_link("Edit", exact: true)
  end

  it "allows admin user to edit file import", :admin, debug: true do
    file = create :file_import
    admin = create :admin

    login_as admin
    visit file_imports_path
    within("div#file-imports") do
      first("a", text: "Edit", exact: true).click
    end
    expect(page).to have_content("Edit #{file.active_storage_attachment.blob.filename}")
    # Select drop down and change status to something else
    # Click on update
    # Verify that within FileImports we have a file import with the changed status

  end
end
