require "rails_helper"

describe SourceFilePolicy do
  permissions :index?, :show?, :update? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      source_file = build(:source_file)

      expect(described_class).to permit(admin, source_file)
    end

    it "grants access if user is a converter" do
      admin = build(:user, :converter)
      source_file = build(:source_file)

      expect(described_class).to permit(admin, source_file)
    end
  end

  permissions :edit?, :destroy?, :destroy_redacted_source_file? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      source_file = build(:source_file)

      expect(described_class).to permit(admin, source_file)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      source_file = build(:source_file)

      expect(described_class).to_not permit(admin, source_file)
    end
  end
end
