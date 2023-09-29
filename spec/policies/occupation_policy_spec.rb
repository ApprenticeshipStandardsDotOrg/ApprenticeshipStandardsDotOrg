require "rails_helper"

describe OccupationPolicy do
  permissions :index?, :show?, :edit?, :update? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      occupation = build(:occupation)

      expect(described_class).to permit(admin, occupation)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      occupation = build(:occupation)

      expect(described_class).to_not permit(admin, occupation)
    end
  end
end
