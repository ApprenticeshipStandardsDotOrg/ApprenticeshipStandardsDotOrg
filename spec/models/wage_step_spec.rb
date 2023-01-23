require "rails_helper"

RSpec.describe WageStep, type: :model do
  it "has a valid factory" do
    wage_step = build(:wage_step)

    expect(wage_step).to be_valid
  end

  it "has unique sort_order wrt occupation_standard" do
    wage_step = create(:wage_step, sort_order: 1)
    new_wage_step = build(:wage_step, occupation_standard: wage_step.occupation_standard, sort_order: 1)

    expect(new_wage_step).to_not be_valid
    new_wage_step.sort_order = 2
    expect(new_wage_step).to be_valid
  end
end
