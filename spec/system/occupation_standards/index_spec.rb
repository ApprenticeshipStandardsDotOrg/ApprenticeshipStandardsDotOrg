require "rails_helper"

RSpec.describe "occupation_standards/index" do
  it "displays titles" do
    mechanic = create(:occupation_standard, :with_data_import, title: "Mechanic")
    pipe_fitter = create(:occupation_standard, :with_data_import, :program_standard, title: "Pipe Fitter")

    visit occupation_standards_path

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
  end

  it "filters occupations based on search term" do
    dental = create(:occupation_standard, :with_data_import, title: "Dental Assistant")
    medical = create(:occupation_standard, :program_standard, :with_data_import, title: "Medical Assistant")
    create(:occupation_standard, :with_data_import, title: "Pipe Fitter")

    visit occupation_standards_path

    fill_in "q", with: "Assistant"

    find("#search").click

    expect(page).to have_text "Showing Results for Assistant"
    expect(page).to have_field("q", with: "Assistant")

    expect(page).to have_link "Dental Assistant", href: occupation_standard_path(dental)
    expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical)
    expect(page).to_not have_link "Pipe Fitter"
  end

  it "filters occupations based on rapids_code search term" do
    mechanic = create(:occupation_standard, :with_data_import, title: "Mechanic", rapids_code: "1234")
    pipe_fitter = create(:occupation_standard, :with_data_import, title: "Pipe Fitter", rapids_code: "1234CB")
    create(:occupation_standard, :with_data_import, title: "HR", rapids_code: "9876")

    visit occupation_standards_path

    fill_in "q", with: "1234"

    find("#search").click

    expect(page).to have_text "Showing Results for 1234"
    expect(page).to have_field("q", with: "1234")

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
    expect(page).to_not have_link "HR"
  end

  it "filters occupations based on onet_code search term" do
    mechanic = create(:occupation_standard, :with_data_import, title: "Mechanic", onet_code: "12.3456")
    pipe_fitter = create(:occupation_standard, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
    create(:occupation_standard, :with_data_import, title: "HR", onet_code: "12.34")

    visit occupation_standards_path

    fill_in "q", with: "12.3456"

    find("#search").click

    expect(page).to have_text "Showing Results for 12.3456"
    expect(page).to have_field("q", with: "12.3456")

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
    expect(page).to_not have_link "HR"
  end

  it "filters occupations based on onet_code search term and state filter", :js do
    wa = create(:state, name: "Washington")
    ra = create(:registration_agency, state: wa)
    mechanic = create(:occupation_standard, :with_data_import, title: "Mechanic", onet_code: "12.3456", registration_agency: ra)
    create(:occupation_standard, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
    create(:occupation_standard, :with_data_import, title: "HR", onet_code: "12.34")

    visit occupation_standards_path

    fill_in "q", with: "12.3456"
    click_on "Expand Filters"
    select "Washington"

    find("#search").click

    expect(page).to have_text "Showing Results for 12.3456"
    expect(page).to have_field("q", with: "12.3456")
    expect(page).to have_field("state_id", with: wa.id)

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to_not have_link "Pipe Fitter"
    expect(page).to_not have_link "HR"
  end

  it "filters occupations based on onet_code search term and national_standard_type filter", :js do
    mechanic = create(:occupation_standard, :program_standard, :with_data_import, title: "Mechanic", onet_code: "12.3456")
    medical_assistant = create(:occupation_standard, :occupational_framework, :with_data_import, title: "Medical Assistant", onet_code: "12.34567")
    create(:occupation_standard, :guideline_standard, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
    create(:occupation_standard, :with_data_import, title: "HR", onet_code: "12.3456")

    visit occupation_standards_path

    fill_in "q", with: "12.3456"
    click_on "Expand Filters"
    find("#dropdownNationalButton").click
    check "National Program Standards"
    check "National Occupational Frameworks"

    find("#search").click

    expect(page).to have_text "Showing Results for 12.3456"
    expect(page).to have_field("q", with: "12.3456")
    find("#dropdownNationalButton").click
    expect(page).to have_checked_field("National Program Standards")
    expect(page).to have_checked_field("National Occupational Frameworks")
    expect(page).to_not have_checked_field("National Guideline Standards")

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical_assistant)
    expect(page).to_not have_link "Pipe Fitter"
    expect(page).to_not have_link "HR"
  end

  it "filters occupations based on onet_code search term and ojt_type filter", :js do
    mechanic = create(:occupation_standard, :hybrid, :with_data_import, title: "Mechanic", onet_code: "12.3456")
    medical_assistant = create(:occupation_standard, :time, :with_data_import, title: "Medical Assistant", onet_code: "12.34567")
    create(:occupation_standard, :competency, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")

    visit occupation_standards_path

    fill_in "q", with: "12.3456"
    click_on "Expand Filters"
    find("#dropdownPrgrmTypeButton").click
    check "Hybrid"
    check "Time"

    find("#search").click

    expect(page).to have_text "Showing Results for 12.3456"
    expect(page).to have_field("q", with: "12.3456")
    find("#dropdownPrgrmTypeButton").click
    expect(page).to have_checked_field("Hybrid")
    expect(page).to have_checked_field("Time")
    expect(page).to_not have_checked_field("Competency")

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical_assistant)
    expect(page).to_not have_link "Pipe Fitter"
    expect(page).to_not have_link "HR"
  end

  it "can clear form", :js do
    wa = create(:state, name: "Washington")
    ra = create(:registration_agency, state: wa)
    mechanic = create(:occupation_standard, :hybrid, :with_data_import, title: "Mechanic", onet_code: "12.3456", registration_agency: ra)
    medical_assistant = create(:occupation_standard, :program_standard, :time, :with_data_import, title: "Medical Assistant", onet_code: "12.34567", registration_agency: ra)
    create(:occupation_standard, :competency, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")

    visit occupation_standards_path

    fill_in "q", with: "12.3456"
    click_on "Expand Filters"
    find("#dropdownPrgrmTypeButton").click
    check "Hybrid"
    check "Time"
    within("#dropdownPrgrmTypeButton") do
      expect(page).to have_text "2"
    end
    select "Washington"
    find("#dropdownNationalButton").click
    check "National Program Standards"
    within("#dropdownNationalButton") do
      expect(page).to have_text "1"
    end

    find("#search").click

    expect(page).to have_text "Showing Results for 12.3456"
    expect(page).to have_field("q", with: "12.3456")
    find("#dropdownPrgrmTypeButton").click
    expect(page).to have_checked_field("Hybrid")
    expect(page).to have_checked_field("Time")
    expect(page).to_not have_checked_field("Competency")
    expect(page).to have_select("state_id", selected: "Washington")
    find("#dropdownNationalButton").click
    expect(page).to have_checked_field("National Program Standards")
    expect(page).to_not have_checked_field("National Occupational Frameworks")
    expect(page).to_not have_checked_field("National Guideline Standards")

    expect(page).to_not have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical_assistant)
    expect(page).to_not have_link "Pipe Fitter"

    click_on "Clear All"
    expect(page).to have_field("q", with: "")
    find("#dropdownPrgrmTypeButton").click
    expect(page).to_not have_checked_field("Hybrid")
    expect(page).to_not have_checked_field("Time")
    expect(page).to_not have_checked_field("Competency")
    expect(page).to have_select("state_id", selected: "")
    within("#dropdownPrgrmTypeButton") do
      expect(page).to_not have_text "2"
      expect(page).to_not have_text "0"
    end
    find("#dropdownNationalButton").click
    expect(page).to_not have_checked_field("National Program Standards")
    expect(page).to_not have_checked_field("National Occupational Frameworks")
    expect(page).to_not have_checked_field("National Guideline Standards")
    within("#dropdownNationalButton") do
      expect(page).to_not have_text "1"
      expect(page).to_not have_text "0"
    end

    find("#search").click

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical_assistant)
    expect(page).to have_link "Pipe Fitter"
  end

  it "shows registration date if available" do
    create(:occupation_standard, :with_data_import, title: "Mechanic", registration_date: Date.parse("October 17, 1989"))

    visit occupation_standards_path

    expect(page).to have_text "Registered 1989"
  end

  it "shows latest updated date if available" do
    create(:occupation_standard, :with_data_import, title: "Mechanic", latest_update_date: Date.parse("October 17, 1989"))

    visit occupation_standards_path

    expect(page).to have_text "Updated 1989"
  end
end
