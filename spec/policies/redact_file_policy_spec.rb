require "rails_helper"

describe RedactFilePolicy do
  permissions :new? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      pdf = build(:imports_pdf)

      expect(described_class).to permit(admin, pdf)
    end

    it "grants access if user is a converter" do
      admin = build(:user, :converter)
      pdf = build(:imports_pdf)

      expect(described_class).to permit(admin, pdf)
    end
  end
end
