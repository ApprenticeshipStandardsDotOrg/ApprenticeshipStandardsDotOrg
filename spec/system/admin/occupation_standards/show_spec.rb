require "rails_helper"

RSpec.describe "admin/occupation_standards/show" do
  it "displays title and description", :admin do
    occupation_standard = create(:occupation_standard, title: "Mechanic", created_at: Time.zone.local(2022, 1, 15, 1, 2, 3), updated_at: Time.zone.local(2022, 6, 17, 10, 11, 12))

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

    expect(page).to have_link("Public view", href: occupation_standard_url(occupation_standard, host: ENV.fetch("PUBLIC_DOMAIN", ENV.fetch("HOST"))))

    expect(page).to have_selector("h1", text: "Mechanic")

    expect(page).to have_selector("dt", text: "Title")
    expect(page).to have_selector("dt", text: "ONET code")
    expect(page).to have_selector("dt", text: "RAPIDS code")
    expect(page).to have_selector("dt", text: "Term months")
    expect(page).to have_selector("dt", text: "URL")
    expect(page).to have_selector("dt", text: "Status")
    expect(page).to have_selector("dt", text: "Created at")
    expect(page).to have_selector("dt", text: "Updated at")

    expect(page).to have_selector("dt", text: "Apprenticeship to journeyworker ratio")
    expect(page).to have_selector("dt", text: "Existing title")
    expect(page).to have_selector("dt", text: "Occupation")
    expect(page).to have_selector("dt", text: "National Standard Type")
    expect(page).to have_selector("dt", text: "OJT type")
    expect(page).to have_selector("dt", text: "Max OJT hours")
    expect(page).to have_selector("dt", text: "Min OJT hours")
    expect(page).to have_selector("dt", text: "Organization")
    expect(page).to have_selector("dt", text: "Probationary period months")
    expect(page).to have_selector("dt", text: "Registration agency")
    expect(page).to have_selector("dt", text: "Max RSI hours")
    expect(page).to have_selector("dt", text: "Min RSI hours")
    expect(page).to have_selector("dt", text: "Data imports")

    expect(page).to have_selector("dd", text: occupation_standard.occupation.title)
    expect(page).to have_selector("dd", text: occupation_standard.onet_code)
    expect(page).to have_selector("dd", text: occupation_standard.rapids_code)
    expect(page).to have_selector("dd", text: occupation_standard.term_months)
    expect(page).to have_selector("dd", text: occupation_standard.url)
    expect(page).to have_selector("dd", text: occupation_standard.status.titleize)
    expect(page).to have_selector("dd", text: "2022-01-15 01:02:03 EST")
    expect(page).to have_selector("dd", text: "2022-06-17 10:11:12 EDT")

    expect(page).to have_selector("dd", text: occupation_standard.apprenticeship_to_journeyworker_ratio)
    expect(page).to have_selector("dd", text: occupation_standard.existing_title)
    expect(page).to have_selector("dd", text: occupation_standard.occupation.title)
    expect(page).to have_selector("dd", text: occupation_standard.national_standard_type&.titleize)
    expect(page).to have_selector("dd", text: "Hybrid")
    expect(page).to have_selector("dd", text: occupation_standard.ojt_hours_max)
    expect(page).to have_selector("dd", text: occupation_standard.ojt_hours_min)
    expect(page).to have_selector("dd", text: occupation_standard.organization&.title)
    expect(page).to have_selector("dd", text: occupation_standard.probationary_period_months)
    expect(page).to have_selector("dd", text: occupation_standard.registration_agency.to_s)
    expect(page).to have_selector("dd", text: occupation_standard.rsi_hours_max)
    expect(page).to have_selector("dd", text: occupation_standard.rsi_hours_min)

    within_grid "Work processes" do
      expect(page).to have_columnheader("Title")
      expect(page).to have_columnheader("Competencies")
      expect(page).to have_columnheader("Minimum Hours")
      expect(page).to have_columnheader("Maximum Hours")

      expect(page).to have_gridcell("WP1")
      expect(page).to have_text("2 competencies")
      expect(page).to have_gridcell "10"
      expect(page).to have_gridcell "20"

      expect(page).to have_gridcell("WP2")
      expect(page).to have_text("0 competencies")
      expect(page).to have_gridcell "4567"
    end

    within_grid "Related instructions" do
      expect(page).to have_columnheader("Title")
      expect(page).to have_columnheader("Hours")

      expect(page).to have_gridcell("RS1")
      expect(page).to have_gridcell "1234"

      expect(page).to have_gridcell("RS2")
      expect(page).to have_gridcell "5678"
    end

    within_grid "Wage steps" do
      expect(page).to have_columnheader("Title")
      expect(page).to have_columnheader("Minimum Hours")
      expect(page).to have_columnheader("OJT Percentage")

      expect(page).to have_gridcell("WS1")
      expect(page).to have_text "3456"
      expect(page).to have_text "50"

      expect(page).to have_gridcell("WS2")
      expect(page).to have_text "75"
    end

    expect(page).to have_link("Edit", href: edit_admin_occupation_standard_path(occupation_standard))
  end

  it "allows for occupation standard not linked to an occupation", :admin do
    occupation_standard = create(:occupation_standard, occupation: nil)
    create(:data_import, occupation_standard: occupation_standard)
    admin = create(:admin)

    login_as admin
    visit admin_occupation_standard_path(occupation_standard)

    expect(page).to have_selector("h1", text: occupation_standard.title)
    expect(page).to have_selector("dt", text: "Occupation")
  end
end
