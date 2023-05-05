require "rails_helper"

RSpec.describe "pages/home" do
  it "filters occupations based on search term" do
    mechanic = create(:occupation_standard, :with_data_import, title: "Mechanic")
    pipe_fitter = create(:occupation_standard, :with_data_import, title: "Pipe Fitter")

    visit home_page_path

    fill_in "q", with: "Mechanic"

    find("#search").click

    expect(page).to have_current_path(occupation_standards_path(q: "Mechanic"))
    expect(page).to have_text "Showing Results for Mechanic"
    expect(page).to have_field("q", with: "Mechanic")

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to_not have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
  end
end
