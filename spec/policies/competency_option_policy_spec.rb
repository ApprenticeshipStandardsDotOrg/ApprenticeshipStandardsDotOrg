require "rails_helper"

describe CompetencyOptionPolicy do
  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      competency_option = build(:competency_option)

      expect(described_class).to permit(admin, competency_option)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      competency_option = build(:competency_option)

      expect(described_class).to_not permit(admin, competency_option)
    end
  end
end
