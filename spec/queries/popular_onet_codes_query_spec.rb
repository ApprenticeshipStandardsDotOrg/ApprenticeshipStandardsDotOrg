require "rails_helper"

RSpec.describe PopularOnetCodesQuery do
  it "returns the onet codes for popular occupation standards" do
    create(:occupation_standard, title: "Medical Assistant", onet_code: "11")
    create_list(:occupation_standard, 2, title: "Pipe Fitter", onet_code: "22")
    create_list(:occupation_standard, 3, title: "Nurse", onet_code: "33")
    create(:occupation_standard, onet_code: nil)

    result = described_class.run(limit: 3)

    expect(result).to eq ["33", "22", "11"]
  end
end
