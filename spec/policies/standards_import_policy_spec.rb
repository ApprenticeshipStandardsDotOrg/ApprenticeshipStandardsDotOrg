require "rails_helper"

describe StandardsImportPolicy do
  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      standards_import = build(:standards_import)

      expect(described_class).to permit(admin, standards_import)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      standards_import = build(:standards_import)

      expect(described_class).to_not permit(admin, standards_import)
    end
  end
end
