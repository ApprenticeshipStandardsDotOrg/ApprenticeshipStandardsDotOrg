require "rails_helper"

RSpec.describe WorkProcess, type: :model do
  it "has a valid factory" do
    wp = build(:work_process)

    expect(wp).to be_valid
  end
end
