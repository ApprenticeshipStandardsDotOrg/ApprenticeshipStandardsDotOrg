require "rails_helper"

RSpec.describe Onet, type: :model do
  it "has a valid factory" do
    onet = build(:onet)

    expect(onet).to be_valid
  end

  it "has unique code wrt version" do
    create(:onet, code: "12-3456.00", version: "2019")
    onet = build(:onet, code: "12-3456.00", version: "2019")

    expect(onet).to_not be_valid

    onet.version = "2020"
    expect(onet).to be_valid
  end

  it "has many next versions" do
    onet_2018 = create(:onet, version: "2018", code: "11-1011")
    onet_2019a = create(:onet, version: "2019", code: "11-1011.00")
    onet_2019b = create(:onet, version: "2019", code: "11-1011.03")

    create(:onet_mapping, onet: onet_2018, next_version_onet: onet_2019a)
    create(:onet_mapping, onet: onet_2018, next_version_onet: onet_2019b)

    expect(onet_2018.next_versions).to contain_exactly(onet_2019a, onet_2019b)
  end

  it "has many previous versions" do
    onet_2018a = create(:onet, version: "2018", code: "11-1011")
    onet_2018b = create(:onet, version: "2018", code: "11-1012")
    onet_2019 = create(:onet, version: "2019", code: "11-1011.00")

    create(:onet_mapping, onet: onet_2018a, next_version_onet: onet_2019)
    create(:onet_mapping, onet: onet_2018b, next_version_onet: onet_2019)

    expect(onet_2019.previous_versions).to contain_exactly(onet_2018a, onet_2018b)
  end

  describe "scopes" do
    describe "current_version" do
      it "returns onet codes with current version only" do
        onet_2018 = create(:onet, version: "2018", code: "11-1011")
        onet_2019a = create(:onet, version: Onet::CURRENT_VERSION, code: "11-1011.00")
        onet_2019b = create(:onet, version: Onet::CURRENT_VERSION, code: "11-1011.03")

        create(:onet_mapping, onet: onet_2018, next_version_onet: onet_2019a)
        create(:onet_mapping, onet: onet_2018, next_version_onet: onet_2019b)

        expect(Onet.current_version).to contain_exactly(onet_2019a, onet_2019b)
      end
    end
  end
end
