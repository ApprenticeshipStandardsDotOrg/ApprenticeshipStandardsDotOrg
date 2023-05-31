require "rails_helper"

describe UserPolicy do
  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy?, :invite? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      user = build(:user)

      expect(described_class).to permit(admin, user)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      user = build(:user)

      expect(described_class).to_not permit(admin, user)
    end
  end
end
