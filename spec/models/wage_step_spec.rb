require 'rails_helper'

RSpec.describe WageStep, type: :model do
    it "has a valid factory" do
    wage_step = build(:wage_step)

    expect(wage_step).to be_valid
  end
end
