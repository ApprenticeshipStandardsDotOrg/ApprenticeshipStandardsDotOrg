require "rails_helper"

RSpec.describe State, type: :model do
  it "has a valid factory" do
    state = build(:state)

    expect(state).to be_valid
  end

  describe "#occupation_standards_count" do
    it "returns an occupation standards count by state" do
      state = create(:state)
      registration_agency = create(:registration_agency, state: state)
      create_list(:occupation_standard, 3, :with_work_processes, registration_agency: registration_agency)

      expect(state.occupation_standards_count).to eq(3)
    end
  end

  describe ".popular" do
    it "returns a list of states by number of occupation standards" do
      ca = create(:state)
      va = create(:state, name: "Virginia", abbreviation: "VA")
      nc = create(:state, name: "North Carolina", abbreviation: "NC")

      ca_agency = registration_agency = create(:registration_agency, state: ca)
      va_agency = registration_agency = create(:registration_agency, state: va)
      nc_agency = registration_agency = create(:registration_agency, state: nc)

      create_list(:occupation_standard, 3, :with_work_processes, registration_agency: ca_agency)
      create(:occupation_standard, :with_work_processes, registration_agency: va_agency)
      create_list(:occupation_standard, 2, :with_work_processes, registration_agency: nc_agency)

      popular = described_class.popular(limit: 2)

      expect(popular.pluck(:abbreviation)).to match_array(["CA", "NC"])
    end
  end
end
