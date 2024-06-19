require "rails_helper"

describe DocsPolicy do
  permissions :index? do
    it "grants access if user is an admin" do
      admin = build(:admin)

      expect(described_class).to permit(admin, :docs)
    end

    it "grants access if user is a converter" do
      converter = build(:user, :converter)

      expect(described_class).to permit(converter, :docs)
    end
  end
end
