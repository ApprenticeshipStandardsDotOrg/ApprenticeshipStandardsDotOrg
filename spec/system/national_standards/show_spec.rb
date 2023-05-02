require "rails_helper"

RSpec.describe "national_standards/show" do
  it "displays national standards of the particular type oonly" do
    mechanic = create(:occupation_standard, :program_standard, title: "Mechanic")
    pipe_fitter = create(:occupation_standard, :program_standard, title: "Pipe Fitter")
    hr = create(:occupation_standard, :guideline_standard, title: "HR")
    medical_assistant = create(:occupation_standard, :occupational_framework, title: "Medical Assistant")

    visit national_standard_path(:program_standard)

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
    expect(page).to_not have_link "HR"
    expect(page).to_not have_link "Medical Assistant"
  end
end
