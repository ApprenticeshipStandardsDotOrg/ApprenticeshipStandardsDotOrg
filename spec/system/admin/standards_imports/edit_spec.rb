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

  it "allows admin to add new files without removing the old ones", :admin do
    import = create(:standards_import, :with_files)
    admin = create(:admin)

    login_as admin
    visit edit_admin_standards_import_path(import)

    file = file_fixture("pixel1x1.jpg")
    find("#standards_import_files").click
    find("#standards_import_files").attach_file(file.to_path)

    click_on "Update"

    import.reload
    expect(import.files.map(&:filename).map(&:to_s)).to contain_exactly("pixel1x1.jpg", "pixel1x1.pdf")
  end
end
