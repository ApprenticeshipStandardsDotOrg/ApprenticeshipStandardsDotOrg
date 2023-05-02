require "rails_helper"

RSpec.describe "national_standards/index" do
  it "displays national standards only" do
    mechanic = create(:occupation_standard, :program_standard, title: "Mechanic")
    pipe_fitter = create(:occupation_standard, :guideline_standard, title: "Pipe Fitter")
    hr = create(:occupation_standard, :occupational_framework, title: "HR")
    create(:occupation_standard, national_standard_type: nil, title: "Medical Assistant")

    visit national_standards_path

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
    expect(page).to have_link "HR", href: occupation_standard_path(hr)
    expect(page).to_not have_link "Medical Assistant"
  end

  it "filters occupations based on search term" do
    mechanic = create(:occupation_standard, title: "Mechanic")
    pipe_fitter = create(:occupation_standard, title: "Pipe Fitter")

    visit occupation_standards_path

    fill_in "q", with: "Mechanic"

    find("#search").click

    expect(page).to have_text "Showing Results for Mechanic"
    expect(page).to have_field("q", with: "Mechanic")

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to_not have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
  end
end
