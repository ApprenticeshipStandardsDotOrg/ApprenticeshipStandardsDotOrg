require "rails_helper"

RSpec.describe StandardsImport, type: :model do
  it "has a valid factory" do
    si = build(:standards_import)

    expect(si).to be_valid
  end
end
