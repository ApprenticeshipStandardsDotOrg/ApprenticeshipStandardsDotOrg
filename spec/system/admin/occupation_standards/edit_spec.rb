require "rails_helper"

RSpec.describe "admin/occupation_standards/edit" do
  it "allows admin user to edit occupation_standard", :admin do
    data_import = create(:data_import)
    occupation_standard = data_import.occupation_standard
    admin = create(:admin)

    login_as admin
    visit edit_admin_occupation_standard_path(occupation_standard)

    expect(page).to have_selector("h1", text: "Edit Mechanic")
    expect(page).to have_field("Title")
    expect(page).to have_field("ONET Code")
    expect(page).to have_field("RAPIDS Code")
    expect(page).to have_select("Status")

    expect(page).to have_selector("h3", text: "Source File")

    within "#work-processes" do
      expect(page).to have_selector("h3", text: "Work Processes")
      expect(page).to have_columnheader("Title")
      expect(page).to have_columnheader("Skills")
      expect(page).to have_columnheader("Hours")
    end

    within "#related-instruction" do
      expect(page).to have_selector("h3", text: "Related Instructions")
      expect(page).to have_columnheader("Title")
      expect(page).to have_columnheader("Hours")
    end

    within "#wage-schedule" do
      expect(page).to have_selector("h3", text: "Wage Schedule")
      expect(page).to have_columnheader("Step Title")
      expect(page).to have_columnheader("Minimum Hours")
      expect(page).to have_columnheader("Minimum OJT %")
    end

    fill_in "Title", with: "New title"
    fill_in "ONET Code", with: "2345.67"
    fill_in "RAPIDS Code", with: "98765"
    select "In Review", from: "Status"
    click_on "Update"

    within("h1") do
      expect(page).to have_content("Occupation Standard for New title")
    end
    expect(page).to have_content "2345.67"
    expect(page).to have_content "98765"
    expect(page).to have_content "In Review"
  end

  it "allows for occupation standard not linked to an occupation", :admin do
    occupation_standard = create(:occupation_standard, occupation: nil, title: "Mechanic")
    create(:data_import, occupation_standard: occupation_standard)
    admin = create(:admin)

    login_as admin
    visit edit_admin_occupation_standard_path(occupation_standard)

    expect(page).to have_selector("h1", text: "Edit Mechanic")
  end
end
