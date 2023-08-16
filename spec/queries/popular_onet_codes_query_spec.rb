require "rails_helper"

RSpec.describe PopularOnetCodesQuery do
  it "returns the onet codes for popular occupation standards" do
    create(:occupation_standard, :with_work_processes, title: "Medical Assistant", onet_code: "11")
    create(:occupation_standard, title: "HR Specialist", onet_code: "12")
    create_list(:occupation_standard, 2, :with_work_processes, title: "Pipe Fitter", onet_code: "22")
    create_list(:occupation_standard, 3, :with_work_processes, title: "Nurse", onet_code: "33")
    create(:occupation_standard, onet_code: nil)

    stub_const("PopularOnetCodesQuery::LIMIT", 4)

    result = described_class.run(limit: 3)

    expect(result).to eq ["33", "22", "11"]
  end
end
