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
end
