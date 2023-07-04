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
      create_list(:occupation_standard, 3, registration_agency: registration_agency)

      expect(state.occupation_standards_count).to eq(3)
    end
  end
end
