require "rails_helper"

RSpec.describe CompetencyOption, type: :model do
  it "has a valid factory for occupation" do
    competency_option = build(:competency_option, :for_occupation)

    expect(competency_option).to be_valid
  end

  it "has a valid factory for competency" do
    competency_option = build(:competency_option, :for_competency)

    expect(competency_option).to be_valid
  end

  it "has unique sort order per resource" do
    competency_option = create(:competency_option, :for_competency, sort_order: 1)
    new_competency_option = build(:competency_option, resource: competency_option.resource, sort_order: 1)

    expect(new_competency_option).to_not be_valid
    new_competency_option.sort_order = 2
    expect(new_competency_option).to be_valid
  end
end
