require "rails_helper"

RSpec.describe "occupations/index" do
  it "displays name and description", :admin do
    occupation = create :occupation
    admin = create :admin

    login_as admin
    visit occupations_path

    expect(page).to have_selector("h2", text: "Occupations")
    expect(page).to have_link(occupation.name, href: occupation_path(occupation))
    expect(page).to have_gridcell(occupation.description)
  end
end
