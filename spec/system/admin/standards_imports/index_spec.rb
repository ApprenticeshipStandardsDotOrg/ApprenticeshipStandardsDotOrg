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

  it "shows and filters by whether standards imports have associated imports", :admin do
    admin = create(:admin)
    standards_import_with_imports = create(:standards_import, name: "With Imports")
    create(:imports_uncategorized, parent: standards_import_with_imports)
    create(:standards_import, name: "Without Imports")

    login_as admin
    visit admin_standards_imports_path

    expect(page).to have_text "Has imports"
    expect(page).to have_link(
      "Has imports",
      href: admin_standards_imports_path(search: "has_imports:true"),
      visible: :all
    )
    expect(page).to have_link(
      "No imports",
      href: admin_standards_imports_path(search: "has_imports:false"),
      visible: :all
    )

    visit admin_standards_imports_path(search: "has_imports:true")

    expect(page).to have_text "With Imports"
    expect(page).to_not have_text "Without Imports"

    visit admin_standards_imports_path(search: "has_imports:false")

    expect(page).to have_text "Without Imports"
    expect(page).to_not have_text "With Imports"
  end
end
