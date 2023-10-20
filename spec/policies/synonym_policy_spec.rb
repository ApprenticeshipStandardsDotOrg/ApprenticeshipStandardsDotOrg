require "rails_helper"

describe SynonymPolicy do
  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      synonym = build(:synonym)

      expect(described_class).to permit(admin, synonym)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      synonym = build(:synonym)

      expect(described_class).to_not permit(admin, synonym)
    end
  end
end
