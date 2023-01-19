require 'rails_helper'

RSpec.describe RelatedInstruction, type: :model do
    it "has a valid factory" do
    related_instruction = build(:related_instruction)

    expect(related_instruction).to be_valid
  end
end
