require "rails_helper"

RSpec.describe RegistrationAgency, type: :model do
  it "has a valid factory" do
    ra = build(:registration_agency)
    
    expect(ra).to be_valid
  end

  it "has unique state wrt agency_type" do
    ra = create(:registration_agency, agency_type: :oa)
    new_ra = build(:registration_agency, state: ra.state, agency_type: ra.agency_type)

    expect(new_ra).to_not be_valid
    new_ra.agency_type = :saa
    expect(new_ra).to be_valid
  end
end
