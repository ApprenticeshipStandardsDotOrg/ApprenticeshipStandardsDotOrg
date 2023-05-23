require "rails_helper"

RSpec.describe "states/index" do
  it "lists states with link to search by state" do
    wa = create(:state, name: "Washington", abbreviation: "WA")
    al = create(:state, name: "Alabama", abbreviation: "AL")

    wa_reg_agency = create(:registration_agency, state: wa)
    al_reg_agency = create(:registration_agency, state: al)

    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", registration_agency: wa_reg_agency)
    create(:occupation_standard, :with_work_processes, :with_data_import, :program_standard, title: "Pipe Fitter", registration_agency: al_reg_agency)

    visit states_path

    expect(page).to have_link "Washington", href: occupation_standards_path(state_id: wa.id)
    expect(page).to have_link "Alabama", href: occupation_standards_path(state_id: al.id)

    click_on "Washington"

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
  end
end
