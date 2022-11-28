require "rails_helper"

RSpec.describe FileImport, type: :model do
  it "has a valid factory" do
    file_import = build(:file_import)

    expect(file_import).to be_valid
  end
end
