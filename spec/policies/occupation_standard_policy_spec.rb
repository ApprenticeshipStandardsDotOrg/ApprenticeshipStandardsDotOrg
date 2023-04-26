require "rails_helper"

describe OccupationStandardPolicy do
  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      occupation_standard = build(:occupation_standard)

      expect(described_class).to permit(admin, occupation_standard)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      occupation_standard = build(:occupation_standard)

      expect(described_class).to_not permit(admin, occupation_standard)
    end
  end
end
