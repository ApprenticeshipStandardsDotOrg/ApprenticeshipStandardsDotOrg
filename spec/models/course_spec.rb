require 'rails_helper'

RSpec.describe Course, type: :model do
  it "has a valid factory" do
    course = build(:course)

    expect(course).to be_valid
  end
end
