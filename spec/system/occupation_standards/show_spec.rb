require "rails_helper"

RSpec.describe "occupation_standards/show" do
  it "displays title" do
    occupation_standard = create(:occupation_standard, :with_data_import)

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_content occupation_standard.title
  end

  it "removes HTML tags from competencies title" do
    occupation_standard = create(:occupation_standard, :with_data_import)
    work_process = create(
      :work_process,
      occupation_standard: occupation_standard,
      title: "Sample Work Process"
    )
    create(
      :competency,
      work_process: work_process,
      title: "<html>Title with<b> HTML</b><html>"
    )

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_content "Title with HTML"
  end

  it "shows registration date if available" do
    occupation_standard = create(:occupation_standard, :with_data_import, registration_date: Date.parse("October 17, 1989"))

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_text "Registered 1989"
  end

  it "shows latest updated date if available" do
    occupation_standard = create(:occupation_standard, :with_data_import, latest_update_date: Date.parse("October 17, 1989"))

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_text "Updated 1989"
  end

  it "shows only redacted document if both public and redacted are available" do
    occupation_standard = create(:occupation_standard, :with_data_import, :with_redacted_document)
    allow_any_instance_of(OccupationStandard).to receive(:public_document?).and_return(true)

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_text "View Redacted Document"
    expect(page).to have_no_text "View Original Document"
  end

  it "shows public document if standards import comes from a public source" do
    occupation_standard = create(:occupation_standard, :with_data_import)
    allow_any_instance_of(OccupationStandard).to receive(:public_document?).and_return(true)

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_text "View Original Document"
    expect(page).to have_no_text "View Redacted Document"
  end

  it "shows message if neither public nor redacted document are available" do
    occupation_standard = create(:occupation_standard, :with_data_import)
    allow_any_instance_of(OccupationStandard).to receive(:public_document?).and_return(false)

    visit occupation_standard_path(occupation_standard)

    within("button[disabled]") do
      expect(page).to have_text "View Redacted Document"
      expect(page).to have_text "Personal and employer info redacted"
    end
  end

  it "shows link to search by onet code if available" do
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", onet_code: "12.3456")

    visit occupation_standard_path(mechanic)

    expect(page).to have_link "12.3456", href: occupation_standards_path(q: "12.3456")
  end

  it "shows link to search by rapids code if available" do
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", rapids_code: "9876")

    visit occupation_standard_path(mechanic)

    expect(page).to have_link "9876", href: occupation_standards_path(q: "9876")
  end

  it "does not show OJT if the occupation standard is competency based" do
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", rapids_code: "9876", ojt_type: :competency)
    create(:work_process, minimum_hours: 500, occupation_standard: mechanic)

    visit occupation_standard_path(mechanic)

    expect(page).not_to have_content "OJT hours"
  end

  it "shows alert if the occupation_standard hours do not meet the occupation required hours" do
    occupation = create(:occupation, time_based_hours: 2000)
    occupation_standard = create(:occupation_standard, :with_data_import, occupation: occupation)
    create(:work_process, maximum_hours: 1000, occupation_standard: occupation_standard)

    visit occupation_standards_path

    expect(page).to have_selector "#hours-alert-#{occupation_standard.id}"
  end

  it "does not show alert if the occupation_standard hours meet the occupation required hours" do
    occupation = create(:occupation, time_based_hours: 2000)
    occupation_standard = create(:occupation_standard, :with_data_import, occupation: occupation)
    create(:work_process, maximum_hours: 3000, occupation_standard: occupation_standard)

    visit occupation_standards_path

    expect(page).to_not have_selector "#hours-alert-#{occupation_standard.id}"
  end

  it "displays toolip on hover", js: true do
    occupation = create(:occupation, time_based_hours: 2000)
    occupation_standard = create(:occupation_standard, :with_data_import, occupation: occupation)
    create(:work_process, maximum_hours: 1000, occupation_standard: occupation_standard)

    visit occupation_standards_path

    find("button[data-tooltip-target='hours-alert-#{occupation_standard.id}']").hover

    expect(page).to have_text "Hours do not meet minimum OA standard for this occupation"
  end
end
