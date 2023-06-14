require "rails_helper"

RSpec.describe ScrapeRAPIDSCode do
  describe "#call" do
    it "creates occupation records" do
      stub_responses
      onet0 = create(:onet, code: "47-4021.00")
      onet1 = create(:onet, code: "17-3026.00")
      onet2 = create(:onet, code: "53-5011.00")
      occupation = create(:occupation, title: "Lift Technician", onet: onet0)

      expect {
        described_class.new.call
      }.to change(Occupation, :count).by(2)

      occupation.reload
      expect(occupation.title).to eq "Lift Technician"
      expect(occupation.rapids_code).to eq "2020"
      expect(occupation.onet).to eq onet0
      expect(occupation.time_based_hours).to eq 4200
      expect(occupation.hybrid_hours_min).to eq 4300
      expect(occupation.hybrid_hours_max).to eq 5250
      expect(occupation.competency_based_hours).to eq 5000

      occ1 = Occupation.second
      expect(occ1.title).to eq "3D Printing Technician"
      expect(occ1.rapids_code).to eq "2078"
      expect(occ1.onet).to eq onet1
      expect(occ1.time_based_hours).to eq 2000
      expect(occ1.hybrid_hours_min).to eq 2500
      expect(occ1.hybrid_hours_max).to eq 4000
      expect(occ1.competency_based_hours).to eq 3000

      occ2 = Occupation.third
      expect(occ2.title).to eq "Able Seaman"
      expect(occ2.rapids_code).to eq "1043"
      expect(occ2.onet).to eq onet2
      expect(occ2.time_based_hours).to eq 2760
      expect(occ2.hybrid_hours_min).to eq 2732
      expect(occ2.hybrid_hours_max).to eq 2732
      expect(occ2.competency_based_hours).to eq 2800
    end
  end

  def stub_responses
    file = file_fixture("scraper/rapids-codes.xlsx")
    stub_request(:get, /www.apprenticeship.gov.*\.xlsx/)
      .to_return(status: 200, body: file.read, headers: {})
  end
end
