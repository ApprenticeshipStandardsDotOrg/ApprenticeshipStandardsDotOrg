require "rails_helper"

RSpec.describe Competency, type: :model do
  it "has a valid factory" do
    competency = build(:competency)

    expect(competency).to be_valid
  end

  it "has unique state wrt agency_type" do
    competency = create(:competency, sort_order: 1)
    new_competency = build(:competency, work_process: competency.work_process, sort_order: 1)

    expect(new_competency).to_not be_valid
    new_competency.sort_order = 2
    expect(new_competency).to be_valid
  end
end
