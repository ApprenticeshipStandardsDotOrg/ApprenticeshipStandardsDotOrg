require 'rails_helper'

RSpec.describe CompetencyEvaluationOption, type: :model do
  it "has a valid factory" do
    evaluation_option = build(:competency_evaluation_option)

    expect(evaluation_option).to be_valid
  end

  it "has unique state wrt agency_type" do
    evaluation_option = create(:competency_evaluation_option, sort_order: 1)
    new_evaluation_option = build(:competency_evaluation_option, resource: evaluation_option.resource, sort_order: 1)

    expect(new_evaluation_option).to_not be_valid
    new_evaluation_option.sort_order = 2
    expect(new_evaluation_option).to be_valid
  end
end
