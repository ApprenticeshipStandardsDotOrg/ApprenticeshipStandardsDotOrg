require "rails_helper"

RSpec.describe "admin/standards_imports/edit" do
  it "allows admin user to edit standards_import", :admin do
    import = create(:standards_import)
    admin = create(:admin)

    login_as admin
    visit edit_admin_standards_import_path(import)

    select "Pending", from: "Courtesy notification"
    click_on "Update"

    expect(page).to have_content "Pending"
  end

  it "allows admin to add new files without removing the old imports", :admin do
    standards_import = create(:standards_import)
    uncat = create(:imports_uncategorized, parent: standards_import)
    admin = create(:admin)

    login_as admin
    visit edit_admin_standards_import_path(standards_import)

    file = file_fixture("pixel1x1.jpg")
    attach_file "Files", [file]

    expect{
      click_on "Update"
    }.to change(Imports::Uncategorized, :count).by(1)

    uncat2 = Imports::Uncategorized.last
    expect(uncat2.filename).to eq "pixel1x1.jpg"
  end
end
