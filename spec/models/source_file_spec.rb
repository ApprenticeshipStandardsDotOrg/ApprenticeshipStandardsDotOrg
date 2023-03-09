require "rails_helper"

RSpec.describe SourceFile, type: :model do
  it "has a valid factory" do
    source_file = build(:source_file)

    expect(source_file).to be_valid
  end
end
