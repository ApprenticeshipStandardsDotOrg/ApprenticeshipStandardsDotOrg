require 'rails_helper'

RSpec.describe OccupationStandard, type: :model do
    it "has a valid factory" do
      occupation_standard = build(:occupation_standard)

      expect(occupation_standard).to be_valid
    end
end
