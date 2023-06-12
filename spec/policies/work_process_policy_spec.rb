require "rails_helper"

describe WorkProcessPolicy do
  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      work_process = build(:work_process)

      expect(described_class).to permit(admin, work_process)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      work_process = build(:work_process)

      expect(described_class).to_not permit(admin, work_process)
    end
  end
end
