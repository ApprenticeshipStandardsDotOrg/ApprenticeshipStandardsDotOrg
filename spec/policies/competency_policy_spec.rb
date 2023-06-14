require "rails_helper"

describe CompetencyPolicy do
  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      competency = build(:competency)

      expect(described_class).to permit(admin, competency)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      competency = build(:competency)

      expect(described_class).to_not permit(admin, competency)
    end
  end
end
