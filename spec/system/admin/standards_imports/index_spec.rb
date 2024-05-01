require "rails_helper"

RSpec.describe "admin/standards_imports/index" do
  it "has a New button that goes to the public page", :admin do
    admin = create(:admin)

    login_as admin
    visit admin_standards_imports_path

    expect(page).to have_link "New standards import", href: new_standards_import_path
    click_on "New standards import"

    expect(page).to have_content "Public document"
  end
end
