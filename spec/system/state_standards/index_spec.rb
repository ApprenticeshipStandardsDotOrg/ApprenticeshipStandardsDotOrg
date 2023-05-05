require "rails_helper"

RSpec.describe "state_standards/index" do
  it "displays state standards only" do
    mechanic = create(:occupation_standard, :state_standard, :with_data_import, title: "Mechanic")
    pipe_fitter = create(:occupation_standard, :state_standard, :with_data_import, title: "Pipe Fitter")
    create(:occupation_standard, :program_standard, title: "Medical Assistant")

    visit state_standards_path

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
    expect(page).to_not have_link "Medical Assistant"
  end

  it "filters state standards based on search term" do
    dental = create(:occupation_standard, :state_standard, :with_data_import, title: "Dental Assistant")
    create(:occupation_standard, :state_standard, :with_data_import, title: "Pipe Fitter")
    create(:occupation_standard, :program_standard, :with_data_import, title: "Medical Assistant")

    visit state_standards_path

    fill_in "q", with: "Assistant"
    find("#search").click

    expect(page).to have_text "Showing Results for Assistant"
    expect(page).to have_field("q", with: "Assistant")

    expect(page).to have_link "Dental Assistant", href: occupation_standard_path(dental)
    expect(page).to_not have_link "Pipe Fitter"
    expect(page).to_not have_link "Medical Assistant"

    fill_in "q", with: "Medical Assistant"
    find("#search").click

    expect(page).to_not have_link "Dental Assistant"
    expect(page).to_not have_link "Pipe Fitter"
    expect(page).to_not have_link "Medical Assistant"
  end
end
