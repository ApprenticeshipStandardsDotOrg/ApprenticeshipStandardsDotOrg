require "rails_helper"

RSpec.describe "admin/source_files/show", :admin do
  it "displays existing data imports and button to upload another" do
    admin = create(:admin)
    source_file = create(:source_file)

    occupation_standard1 = create(:occupation_standard, title: "Mechanic")
    data_import1 = create(:data_import, source_file: source_file, occupation_standard: occupation_standard1)

    data_import2 = create(:data_import, :hybrid, source_file: source_file, occupation_standard: nil)

    login_as admin
    visit admin_source_file_path(source_file)

    expect(page).to have_content "Show #{source_file.filename}"

    expect(page).to have_link "Edit", href: edit_admin_source_file_data_import_path(source_file, data_import1)
    expect(page).to have_link "occupation-standards-template.xlsx", href: admin_source_file_data_import_path(source_file, data_import1)
    expect(page).to have_link "Mechanic", href: admin_occupation_standard_path(occupation_standard1)

    expect(page).to have_link "Edit", href: edit_admin_source_file_data_import_path(source_file, data_import2)

    expect(page).to have_link "New data import", href: new_admin_source_file_data_import_path(source_file)
    expect(page).to_not have_button "Needs support"
  end

  it "has Needs support button viewable for converters" do
    converter = create(:user, :converter)
    source_file = create(:source_file)

    occupation_standard1 = create(:occupation_standard, title: "Mechanic")
    data_import1 = create(:data_import, source_file: source_file, occupation_standard: occupation_standard1)

    login_as converter
    visit admin_source_file_path(source_file)

    expect(page).to have_content "Show #{source_file.filename}"

    within("dd", match: :first) do
      expect(page).to have_text "Pending"
    end
    expect(page).to_not have_link "Edit", href: edit_admin_source_file_data_import_path(source_file, data_import1)
    expect(page).to have_link "occupation-standards-template.xlsx", href: admin_source_file_data_import_path(source_file, data_import1)
    expect(page).to_not have_link "Mechanic", href: admin_occupation_standard_path(occupation_standard1)

    expect(page).to have_link "New data import", href: new_admin_source_file_data_import_path(source_file)
    expect(page).to have_button "Needs support"

    click_on "Needs support"

    within("dd", match: :first) do
      expect(page).to have_text "Needs Support"
    end
  end

  it "allows admin to remove a redacted file" do
    admin = create(:user, :admin)
    source_file = create(:source_file, :with_redacted_source_file)

    login_as admin
    visit admin_source_file_path(source_file)

    expect(page).to have_text source_file.redacted_source_file.filename

    expect(page).to have_link(
      "Remove",
      href: redacted_source_file_admin_source_file_path(
        source_file,
        attachment_id: source_file.redacted_source_file.id
      )
    )

    click_link "Remove"

    expect(page).to_not have_text source_file.redacted_source_file.filename
    expect(page).to have_text "No attachment"
    expect(page).to_not have_link "Remove"
  end

  it "prevents converter users to remove a redacted file" do
    converter = create(:user, :converter)
    source_file = create(:source_file, :with_redacted_source_file)

    login_as converter
    visit admin_source_file_path(source_file)

    expect(page).to have_text source_file.redacted_source_file.filename
    expect(page).to_not have_link "Remove"
  end
end
