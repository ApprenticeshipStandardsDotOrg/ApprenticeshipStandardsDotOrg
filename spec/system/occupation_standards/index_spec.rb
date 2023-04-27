require "rails_helper"

RSpec.describe "occupation_standards/index" do
  it "displays titles" do
    mechanic = create(:occupation_standard, title: "Mechanic")
    pipe_fitter = create(:occupation_standard, title: "Pipe Fitter")

    visit occupation_standards_path

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
  end

  it "filters occupations based on search term" do
    mechanic = create(:occupation_standard, title: "Mechanic")
    pipe_fitter = create(:occupation_standard, title: "Pipe Fitter")

    visit occupation_standards_path

    fill_in "q", with: "Mechanic"

    click_button "button"

    expect(page).to have_text "Showing Results for Mec"

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to_not have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
  end
end
