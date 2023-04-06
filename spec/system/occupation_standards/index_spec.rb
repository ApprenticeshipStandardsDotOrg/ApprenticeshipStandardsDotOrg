require "rails_helper"

RSpec.describe "occupation_standards/index" do
  it "displays titles" do
    pending("modifying homepage to display actual data")
    create(:occupation_standard, title: "Mechanic")
    create(:occupation_standard, title: "Pipe Fitter")

    visit occupation_standards_path

    expect(page).to have_content "Mechanic"
    expect(page).to have_content "Pipe Fitter"
  end
end
