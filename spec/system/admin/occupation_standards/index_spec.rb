require "rails_helper"

RSpec.describe "admin/occupation_standards/index", :admin do
  it "can search by agency" do
    alabama = create(:state, name: "Alabama", abbreviation: "AL")
    reg_agency = create(:registration_agency, :saa, state: alabama)
    os = create(:occupation_standard, registration_agency: reg_agency)
    admin = create(:admin)

    login_as admin
    visit admin_occupation_standards_path(search: "alabama")

    expect(page).to have_text("Alabama (SAA)")
  end
end
