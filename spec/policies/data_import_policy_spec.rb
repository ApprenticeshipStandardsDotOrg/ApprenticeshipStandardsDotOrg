require "rails_helper"

describe DataImportPolicy do
  permissions :show?, :new?, :create? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      data_import = build(:data_import)

      expect(described_class).to permit(admin, data_import)
    end

    it "grants access if user is a converter" do
      admin = build(:user, :converter)
      data_import = build(:data_import)

      expect(described_class).to permit(admin, data_import)
    end
  end

  permissions :edit?, :update?, :destroy? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      data_import = build(:data_import)

      expect(described_class).to permit(admin, data_import)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      data_import = build(:data_import)

      expect(described_class).to_not permit(admin, data_import)
    end
  end
end
