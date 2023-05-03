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
end
