require "rails_helper"

RSpec.describe State, type: :model do
  it "has a valid factory" do
    state = build(:state)

    expect(state).to be_valid
  end

  describe "#occupation_standards_count" do
    it "returns an occupation standards count by state" do
      registration_agency = create(:registration_agency)
      create_list(:occupation_standard, 3, :with_work_processes, registration_agency: registration_agency)

      expect(registration_agency.state.occupation_standards_count).to eq(3)
    end
  end

  describe ".popular" do
    it "returns a list of states by number of occupation standards" do
      ca_agency = create(:registration_agency, for_state_abbreviation: "CA")
      va_agency = create(:registration_agency, for_state_abbreviation: "VA")
      nc_agency = create(:registration_agency, for_state_abbreviation: "NC")

      create_list(:occupation_standard, 3, :with_work_processes, registration_agency: ca_agency)
      create(:occupation_standard, :with_work_processes, registration_agency: va_agency)
      create_list(:occupation_standard, 2, :with_work_processes, registration_agency: nc_agency)

      popular = described_class.popular(limit: 2)

      expect(popular.pluck(:abbreviation)).to match_array(["CA", "NC"])
    end
  end
end
