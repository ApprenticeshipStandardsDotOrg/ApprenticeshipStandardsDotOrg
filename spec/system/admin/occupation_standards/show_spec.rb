require "rails_helper"

RSpec.describe "admin/occupation_standards/show" do
  it "displays title and description", :admin do
    occupation_standard = create(:occupation_standard, title: "Mechanic")

    work_process = create(:work_process, occupation_standard: occupation_standard, minimum_hours: 10, maximum_hours: 20, title: "WP1")
    create_pair(:competency, work_process: work_process)
    create(:work_process, occupation_standard: occupation_standard, minimum_hours: 4567, maximum_hours: 4567, title: "WP2")

    create(:related_instruction, occupation_standard: occupation_standard, title: "RS1", hours: 1234)
    create(:related_instruction, occupation_standard: occupation_standard, title: "RS2", hours: 5678)

    create(:wage_step, occupation_standard: occupation_standard, title: "WS1", minimum_hours: 3456, ojt_percentage: 50)
    create(:wage_step, occupation_standard: occupation_standard, title: "WS2", minimum_hours: 7890, ojt_percentage: 75)

    create(:data_import, occupation_standard: occupation_standard)
    admin = create(:admin)

    login_as admin
    visit admin_occupation_standard_path(occupation_standard)

    expect(page).to have_selector("h1", text: "Occupation Standard for Mechanic")

    expect(page).to have_selector("dt", text: "Occupation:")
    expect(page).to have_selector("dt", text: "URL:")
    expect(page).to have_selector("dt", text: "Registration Agency:")
    expect(page).to have_selector("dt", text: "RAPIDS code:")
    expect(page).to have_selector("dt", text: "ONET code:")
    expect(page).to have_selector("dt", text: "Created at:")
    expect(page).to have_selector("dt", text: "Updated at:")

    expect(page).to have_selector("dd", text: occupation_standard.occupation.title)
    expect(page).to have_selector("dd", text: occupation_standard.url)
    expect(page).to have_selector("dd", text: occupation_standard.registration_agency)
    expect(page).to have_selector("dd", text: occupation_standard.rapids_code)
    expect(page).to have_selector("dd", text: occupation_standard.onet_code)
    expect(page).to have_selector("dd", text: occupation_standard.created_at)
    expect(page).to have_selector("dd", text: occupation_standard.updated_at)

    within "#work-processes" do
      expect(page).to have_selector("h3", text: "Work Processes")
      expect(page).to have_columnheader("Title")
      expect(page).to have_columnheader("Skills")
      expect(page).to have_columnheader("Hours")

      expect(page).to have_link("WP1", href: "#")
      expect(page).to have_link("2", href: "#")
      expect(page).to have_text "10-20"

      expect(page).to have_link("WP2", href: "#")
      expect(page).to have_text("0")
      expect(page).to_not have_link("0")
      expect(page).to have_text "4567"
    end

    within "#related-instruction" do
      expect(page).to have_selector("h3", text: "Related Instructions")
      expect(page).to have_columnheader("Title")
      expect(page).to have_columnheader("Hours")

      expect(page).to have_link("RS1", href: "#")
      expect(page).to have_text "1234"

      expect(page).to have_link("RS2", href: "#")
      expect(page).to have_text "5678"
    end

    within "#wage-schedule" do
      expect(page).to have_selector("h3", text: "Wage Schedule")
      expect(page).to have_columnheader("Step Title")
      expect(page).to have_columnheader("Minimum Hours")
      expect(page).to have_columnheader("Minimum OJT %")

      expect(page).to have_link("WS1", href: "#")
      expect(page).to have_text "3456"
      expect(page).to have_text "50%"

      expect(page).to have_link("WS2", href: "#")
      expect(page).to have_text "75%"
    end

    expect(page).to have_link("Edit", href: edit_admin_occupation_standard_path(occupation_standard))
  end

  it "allows for occupation standard not linked to an occupation", :admin do
    occupation_standard = create(:occupation_standard, occupation: nil)
    create(:data_import, occupation_standard: occupation_standard)
    admin = create(:admin)

    login_as admin
    visit admin_occupation_standard_path(occupation_standard)

    expect(page).to have_selector("h1", text: "Occupation Standard for #{occupation_standard.title}")
    expect(page).to have_selector("dt", text: "Occupation:")
  end
end
