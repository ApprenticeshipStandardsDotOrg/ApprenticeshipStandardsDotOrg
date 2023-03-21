require "rails_helper"

RSpec.describe "occupation_standards/show" do
  it "displays title" do
    occupation_standard = create(:occupation_standard, title: "Mechanic")

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_content "Mechanic"
  end
end
