require "rails_helper"

describe APIKeyPolicy do
  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      api_key = build(:api_key)

      expect(described_class).to permit(admin, api_key)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      api_key = build(:api_key)

      expect(described_class).to_not permit(admin, api_key)
    end
  end
end
