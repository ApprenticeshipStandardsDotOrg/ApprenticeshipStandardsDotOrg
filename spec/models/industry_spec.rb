require 'rails_helper'

RSpec.describe Industry, type: :model do
  it "has a valid factory" do
    industry = build(:industry)

    expect(industry).to be_valid
  end
end
