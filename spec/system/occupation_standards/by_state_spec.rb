require "rails_helper"

RSpec.describe ":state_abbreviation/occupation_standards" do
  it "shows occupations from registration matching state initials" do
    new_york = create(:state, name: "New York", abbreviation: "NY")
    nevada = create(:state, name: "Nevada", abbreviation: "NV")

    new_york_registration_agency = create(:registration_agency, state: new_york)
    nevada_registration_agency = create(:registration_agency, state: nevada)

    mechanic_from_new_york = create(:occupation_standard,
      :with_work_processes,
      :with_data_import,
      title: "Mechanic",
      registration_agency: new_york_registration_agency)
    mechanic_from_nevada = create(:occupation_standard,
      :with_work_processes,
      :with_data_import,
      title: "Mechanic",
      registration_agency: nevada_registration_agency)

    visit occupation_standards_by_state_path(state_abbreviation: new_york.abbreviation)

    expect(page).to have_text "Showing Results for New York"
    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic_from_new_york)
    expect(page).not_to have_link "Mechanic", href: occupation_standard_path(mechanic_from_nevada)
  end

  it "shows no results when state does not exist" do
    visit occupation_standards_by_state_path(state_abbreviation: "INVALID")

    expect(page).to have_no_text "Showing Results for"
  end
end
