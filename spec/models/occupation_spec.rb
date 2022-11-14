require "rails_helper"

RSpec.describe Occupation, type: :model do
  it "has a valid factory" do
    occupation = build(:occupation)

    expect(occupation).to be_valid
  end
end
