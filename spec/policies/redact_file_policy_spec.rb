require "rails_helper"

describe RedactFilePolicy do
  permissions :new? do
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
end
