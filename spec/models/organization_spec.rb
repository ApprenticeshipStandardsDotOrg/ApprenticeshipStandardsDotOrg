require "rails_helper"

RSpec.describe Organization, type: :model do
  it "has a valid factory" do
    organization = build(:organization)

    expect(organization).to be_valid
  end

  describe ".related_instructions_organizations" do
    it "returns all unique organizations related to an occupation standard through its related instructions" do
      occupation_standard = create(:occupation_standard)
      organization = create(:organization)

      create(:related_instruction,
             occupation_standard: occupation_standard,
             organization: organization,
             sort_order: 1
            )

      create(:related_instruction,
             occupation_standard: occupation_standard,
             organization: organization,
             sort_order: 2
            )

      expect(
        described_class.related_instructions_organizations(occupation_standard).pluck(:id)
      ).to match_array [organization.id]
    end

    it "returns empty array if no related instructions" do
      occupation_standard = build(:occupation_standard)

      expect(
        described_class.related_instructions_organizations(occupation_standard)
      ).to be_empty
    end
  end
end
