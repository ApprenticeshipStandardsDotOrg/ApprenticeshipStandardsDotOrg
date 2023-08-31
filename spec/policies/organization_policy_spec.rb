require "rails_helper"

describe OccupationStandardPolicy do
  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      organization = build(:organization)

      expect(described_class).to permit(admin, organization)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      organization = build(:organization)

      expect(described_class).to_not permit(admin, organization)
    end
  end
end
