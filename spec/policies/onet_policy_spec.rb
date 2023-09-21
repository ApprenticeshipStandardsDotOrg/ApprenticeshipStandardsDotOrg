require "rails_helper"

describe OnetPolicy do
  permissions :index?, :show? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      onet = build(:onet)

      expect(described_class).to permit(admin, onet)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      onet = build(:onet)

      expect(described_class).to_not permit(admin, onet)
    end
  end
end
