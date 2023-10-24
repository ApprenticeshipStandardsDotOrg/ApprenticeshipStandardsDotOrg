require "rails_helper"

RSpec.describe OnetMapping, type: :model do
  it "has a valid factory" do
    onet_mapping = build(:onet_mapping)

    expect(onet_mapping).to be_valid
  end

  it "is unique wrt onet_id, next_version_onet_id" do
    onet_mapping = create(:onet_mapping)
    new_onet_mapping = build(:onet_mapping, onet: onet_mapping.onet, next_version_onet: onet_mapping.next_version_onet)

    expect(new_onet_mapping).to_not be_valid
  end
end
