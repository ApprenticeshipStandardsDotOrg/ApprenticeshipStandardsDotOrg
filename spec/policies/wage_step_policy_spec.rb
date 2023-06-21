require "rails_helper"

describe WageStepPolicy do
  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      wage_step = build(:wage_step)

      expect(described_class).to permit(admin, wage_step)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      wage_step = build(:wage_step)

      expect(described_class).to_not permit(admin, wage_step)
    end
  end
end
