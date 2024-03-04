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

  describe ".registration_agency_for_national_program" do
    it "returns nil if there is no registration agency without an state" do
      expect(described_class.registration_agency_for_national_program).to be nil
    end

    it "returns registration agency without an state if present" do
      registration_agency = create(:registration_agency, state: nil)

      expect(described_class.registration_agency_for_national_program).to eq registration_agency
    end
  end

  describe "#to_s" do
    it "returns state name and agency type" do
      ca = build_stubbed(:state, name: "California")
      ra = build(:registration_agency, state: ca, agency_type: :saa)

      expect(ra.to_s).to eq "California (SAA)"
    end
  end
end
