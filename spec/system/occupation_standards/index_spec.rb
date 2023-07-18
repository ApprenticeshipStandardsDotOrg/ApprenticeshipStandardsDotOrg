require "rails_helper"

RSpec.describe "occupation_standards/index" do
  it "displays titles" do
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
    pipe_fitter = create(:occupation_standard, :with_work_processes, :with_data_import, :program_standard, title: "Pipe Fitter")

    visit occupation_standards_path

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
  end

  it "displays only OJT hours and not skills for time-based standards" do
    mechanic = create(:occupation_standard, :time, :with_data_import, title: "Mechanic")
    work_process = create(:work_process, occupation_standard: mechanic, maximum_hours: 200)
    create(:competency, work_process: work_process)

    visit occupation_standards_path

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_text "OJT hours"
    expect(page).to_not have_text "Skills"
  end

  it "displays only skills and not OJT hours for competency-based standards" do
    mechanic = create(:occupation_standard, :competency, :with_data_import, title: "Mechanic")
    work_process = create(:work_process, occupation_standard: mechanic, maximum_hours: 200)
    create(:competency, work_process: work_process)

    visit occupation_standards_path

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to_not have_text "OJT hours"
    expect(page).to have_text "Skills"
  end

  it "displays skills and OJT hours for hybrid-based standards" do
    mechanic = create(:occupation_standard, :hybrid, :with_data_import, title: "Mechanic")
    work_process = create(:work_process, occupation_standard: mechanic, maximum_hours: 200)
    create(:competency, work_process: work_process)

    visit occupation_standards_path

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_text "OJT hours"
    expect(page).to have_text "Skills"
  end

  it "filters occupations based on search term" do
    dental = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Dental Assistant")
    medical = create(:occupation_standard, :with_work_processes, :program_standard, :with_data_import, title: "Medical Assistant")
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter")

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
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", rapids_code: "1234")
    pipe_fitter = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter", rapids_code: "1234CB")
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", rapids_code: "9876")

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
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", onet_code: "12.3456")
    pipe_fitter = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.34")

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
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", onet_code: "12.3456", registration_agency: ra)
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.34")

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
    mechanic = create(:occupation_standard, :with_work_processes, :program_standard, :with_data_import, title: "Mechanic", onet_code: "12.3456")
    medical_assistant = create(:occupation_standard, :with_work_processes, :occupational_framework, :with_data_import, title: "Medical Assistant", onet_code: "12.34567")
    create(:occupation_standard, :with_work_processes, :guideline_standard, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.3456")

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
    mechanic = create(:occupation_standard, :with_work_processes, :hybrid, :with_data_import, title: "Mechanic", onet_code: "12.3456")
    medical_assistant = create(:occupation_standard, :with_work_processes, :time, :with_data_import, title: "Medical Assistant", onet_code: "12.34567")
    create(:occupation_standard, :with_work_processes, :competency, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")

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

  it "filters occupations with state shortcode" do
    washington = create(:state, name: "Washington", abbreviation: "WA")
    washington_registration_agency = create(:registration_agency, state: washington)
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", onet_code: "12.3456", registration_agency: washington_registration_agency)
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.34")

    visit occupation_standards_path

    fill_in "q", with: "state:wa 12.3456"

    find("#search").click

    expect(page).to have_text "Showing Results for 12.3456"
    expect(page).to have_field("q", with: "state:wa 12.3456")

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to_not have_link "Pipe Fitter"
    expect(page).to_not have_link "HR"
  end

  it "filters occupations with national_standard_type shortcode" do
    mechanic = create(:occupation_standard, :with_work_processes, :program_standard, :with_data_import, title: "Mechanic", onet_code: "12.3456")
    create(:occupation_standard, :with_work_processes, :occupational_framework, :with_data_import, title: "Medical Assistant", onet_code: "12.34567")
    create(:occupation_standard, :with_work_processes, :guideline_standard, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.3456")

    visit occupation_standards_path

    fill_in "q", with: "12.3456 national_standard_type:program_standard"

    find("#search").click

    expect(page).to have_text "Showing Results for 12.3456"
    expect(page).to have_field("q", with: "12.3456 national_standard_type:program_standard")
    find("#dropdownNationalButton").click

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to_not have_link "Medical Assistant"
    expect(page).to_not have_link "Pipe Fitter"
    expect(page).to_not have_link "HR"
  end

  it "filters occupations with ojt_type shortcode" do
    mechanic = create(:occupation_standard, :with_work_processes, :hybrid, :with_data_import, title: "Mechanic", onet_code: "12.3456")
    create(:occupation_standard, :with_work_processes, :time, :with_data_import, title: "Medical Assistant", onet_code: "12.34567")
    create(:occupation_standard, :with_work_processes, :competency, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")

    visit occupation_standards_path

    fill_in "q", with: "12.3456 ojt_type:hybrid"

    find("#search").click

    expect(page).to have_text "Showing Results for 12.3456"
    expect(page).to have_field("q", with: "12.3456 ojt_type:hybrid")

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to_not have_link "Medical Assistant"
    expect(page).to_not have_link "Pipe Fitter"
    expect(page).to_not have_link "HR"
  end

  it "can clear form", :js do
    wa = create(:state, name: "Washington")
    ra = create(:registration_agency, state: wa)
    mechanic = create(:occupation_standard, :with_work_processes, :hybrid, :with_data_import, title: "Mechanic", onet_code: "12.3456", registration_agency: ra)
    medical_assistant = create(:occupation_standard, :with_work_processes, :program_standard, :time, :with_data_import, title: "Medical Assistant", onet_code: "12.34567", registration_agency: ra)
    create(:occupation_standard, :with_work_processes, :competency, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")

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
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", registration_date: Date.parse("October 17, 1989"))

    visit occupation_standards_path

    expect(page).to have_text "Registered 1989"
  end

  it "shows latest updated date if available" do
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", latest_update_date: Date.parse("October 17, 1989"))

    visit occupation_standards_path

    expect(page).to have_text "Updated 1989"
  end

  it "shows link to search by onet code if available" do
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", onet_code: "12.3456")

    visit occupation_standards_path

    expect(page).to have_link "12.3456", href: occupation_standards_path(q: mechanic.onet_code)
  end

  it "shows link to search by rapids code if available" do
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", rapids_code: "9876")

    visit occupation_standards_path

    expect(page).to have_link "9876", href: occupation_standards_path(q: mechanic.rapids_code)
  end

  it "shows suggestions based on occupation title", :js do
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
    pipe_fitter = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter")

    visit occupation_standards_path

    expect(page).to_not have_selector "div", class: "tt-suggestion"

    fill_in "q", with: "Mec"

    expect(page).to have_selector "div", class: "tt-suggestion", text: mechanic.display_for_typeahead
    expect(page).to_not have_selector "div", class: "tt-suggestion", text: pipe_fitter.display_for_typeahead
  end

  it "shows suggestions based on onet code", :js do
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", onet_code: "12-1234")
    pipe_fitter = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter", onet_code: "51-6789")

    visit occupation_standards_path

    expect(page).to_not have_selector "div", class: "tt-suggestion"

    fill_in "q", with: "12-"

    expect(page).to have_selector "div", class: "tt-suggestion", text: mechanic.display_for_typeahead
    expect(page).to_not have_selector "div", class: "tt-suggestion", text: pipe_fitter.display_for_typeahead
  end

  it "shows suggestions based on rapids code", :js do
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", rapids_code: "9108")
    pipe_fitter = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter", rapids_code: "1582")

    visit occupation_standards_path

    expect(page).to_not have_selector "div", class: "tt-suggestion"

    fill_in "q", with: "9108"

    expect(page).to have_selector "div", class: "tt-suggestion", text: mechanic.display_for_typeahead
    expect(page).to_not have_selector "div", class: "tt-suggestion", text: pipe_fitter.display_for_typeahead
  end

  it "shows similar results accordion button if they are present" do
    Flipper.enable :similar_programs_accordion
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
    create(:occupation_standard, :with_work_processes, :with_data_import, :program_standard, title: "Mechanic")

    visit occupation_standards_path

    expect(page).to have_text "1 program with similar or identical criteria."
  end

  it "does not show similar results accordion button if they are not present" do
    Flipper.enable :similar_programs_accordion
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
    create(:occupation_standard, :with_work_processes, :with_data_import, :program_standard, title: "Pipe Fitter")

    visit occupation_standards_path

    expect(page).not_to have_text "program with similar or identical criteria."
  end

  it "expands similar results accordion when accordion button is clicked", js: true do
    Flipper.enable :similar_programs_accordion
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
    create(:occupation_standard, :with_work_processes, :with_data_import, :program_standard, title: "Mechanic")

    visit occupation_standards_path

    find('button[data-action="click->accordion#changeVisibility"]', match: :first).click

    expect(page).to have_selector(:button, "Collapse duplicates")
  end

  it "closes similar results accordion when accordion button is clicked", js: true do
    Flipper.enable :similar_programs_accordion
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
    create(:occupation_standard, :with_work_processes, :with_data_import, :program_standard, title: "Mechanic")

    visit occupation_standards_path

    find('button[data-action="click->accordion#changeVisibility"]', match: :first).click

    within "#accordion-#{mechanic.id}" do
      click_on "Collapse duplicates"
    end

    expect(page).not_to have_selector("#accordion-#{mechanic.id}")
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

    expect(page).to have_text "Hours do not match"
  end
end
