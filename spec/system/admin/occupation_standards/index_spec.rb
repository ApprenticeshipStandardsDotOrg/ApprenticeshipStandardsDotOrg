require "rails_helper"

RSpec.describe "admin/occupation_standards/index", :admin do
  it "can search by agency" do
    alabama = create(:state, name: "Alabama")
    al_reg_agency = create(:registration_agency, :saa, state: alabama)
    create(:occupation_standard, registration_agency: al_reg_agency)

    california = State.find_by(name: "California") || create(:state, name: "California")
    ca_reg_agency = create(:registration_agency, :oa, state: california)
    create(:occupation_standard, registration_agency: ca_reg_agency)

    admin = create(:admin)

    login_as admin
    visit admin_occupation_standards_path

    expect(page).to have_text("Alabama (SAA)")
    expect(page).to have_text("California (OA)")

    visit admin_occupation_standards_path(search: "alabama")

    expect(page).to have_text("Alabama (SAA)")
    expect(page).to_not have_text("California (OA)")
  end

  it "can search by occupation" do
    coppersmith = create(:occupation, title: "COPPERSMITH")
    create(:occupation_standard, occupation: coppersmith, title: "os 1")

    mechanic = create(:occupation, title: "Mechanic")
    create(:occupation_standard, occupation: mechanic, title: "os 2")

    admin = create(:admin)

    login_as admin
    visit admin_occupation_standards_path

    expect(page).to have_text("COPPERSMITH")
    expect(page).to have_text("Mechanic")

    visit admin_occupation_standards_path(search: "copper")

    expect(page).to have_text("COPPERSMITH")
    expect(page).to_not have_text("Mechanic")
  end
end
