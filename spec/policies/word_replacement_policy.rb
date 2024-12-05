require "rails_helper"

describe WordReplacementPolicy do
  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy? do
    it "grants access if user is an admin" do
      admin = build(:admin)
      word_replacement = build(:word_replacement)

      expect(described_class).to permit(admin, word_replacement)
    end

    it "denies access if user is a converter" do
      admin = build(:user, :converter)
      word_replacement = build(:word_replacement)

      expect(described_class).to_not permit(admin, word_replacement)
    end
  end
end
