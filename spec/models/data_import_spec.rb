require 'rails_helper'

RSpec.describe DataImport, type: :model do
  it "has a valid factory" do
    data_import = build(:data_import)

    expect(data_import).to be_valid
  end
end
