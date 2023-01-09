require 'rails_helper'

RSpec.describe State, type: :model do
  it "has a valid factory" do
    state = build(:state)
    
    expect(state).to be_valid
  end
end
