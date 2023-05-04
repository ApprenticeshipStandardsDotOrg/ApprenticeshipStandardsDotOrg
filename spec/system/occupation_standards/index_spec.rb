require "rails_helper"

RSpec.describe "occupation_standards/index" do
  it "displays titles" do
    mechanic = create(:occupation_standard, title: "Mechanic")
    pipe_fitter = create(:occupation_standard, :program_standard, title: "Pipe Fitter")

    visit occupation_standards_path

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
  end

  it "filters occupations based on search term" do
    dental = create(:occupation_standard, title: "Dental Assistant")
    medical = create(:occupation_standard, :program_standard, title: "Medical Assistant")
    create(:occupation_standard, title: "Pipe Fitter")

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
    mechanic = create(:occupation_standard, title: "Mechanic", rapids_code: "1234")
    pipe_fitter = create(:occupation_standard, title: "Pipe Fitter", rapids_code: "1234CB")
    create(:occupation_standard, title: "HR", rapids_code: "9876")

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
    mechanic = create(:occupation_standard, title: "Mechanic", onet_code: "12.3456")
    pipe_fitter = create(:occupation_standard, title: "Pipe Fitter", onet_code: "12.34567")
    create(:occupation_standard, title: "HR", onet_code: "12.34")

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
    mechanic = create(:occupation_standard, title: "Mechanic", onet_code: "12.3456", registration_agency: ra)
    create(:occupation_standard, title: "Pipe Fitter", onet_code: "12.34567")
    create(:occupation_standard, title: "HR", onet_code: "12.34")

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
    mechanic = create(:occupation_standard, :program_standard, title: "Mechanic", onet_code: "12.3456")
    ma = create(:occupation_standard, :occupational_framework, title: "Medical Assistant", onet_code: "12.34567")
    create(:occupation_standard, :guideline_standard, title: "Pipe Fitter", onet_code: "12.34567")
    create(:occupation_standard, title: "HR", onet_code: "12.3456")

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

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_link "Medical Assistant", href: occupation_standard_path(ma)
    expect(page).to_not have_link "Pipe Fitter"
    expect(page).to_not have_link "HR"
  end
end
