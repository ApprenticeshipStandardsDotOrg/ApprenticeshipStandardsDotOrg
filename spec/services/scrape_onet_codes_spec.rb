require "rails_helper"

RSpec.describe ScrapeOnetCodes do
  describe "#call" do
    it "creates onet records" do
      stub_responses
      onet = create(:onet, title: "Not actually an actuary", code: "15-2011.00")

      service = instance_double("OnetWebService", call: nil)
      expect(OnetWebService).to receive(:new).and_return(service).exactly(4).times
      expect(service).to receive(:call).exactly(4).times

      expect {
        described_class.new.call
      }.to change(Onet, :count).by(3)

      onet.reload
      expect(onet.title).to eq "Actuaries"
      expect(onet.code).to eq "15-2011.00"
      expect(onet.version).to eq "2019"

      onet1 = Onet.second
      expect(onet1.title).to eq "Accountants and Auditors"
      expect(onet1.code).to eq "13-2011.00"
      expect(onet1.version).to eq "2019"

      onet2 = Onet.third
      expect(onet2.title).to eq "Actors"
      expect(onet2.code).to eq "27-2011.00"
      expect(onet2.version).to eq "2019"

      onet3 = Onet.fourth
      expect(onet3.title).to eq "Aerospace Engineers"
      expect(onet3.code).to eq "17-2011.00"
      expect(onet3.version).to eq "2019"
    end
  end

  def stub_responses
    file = file_fixture("scraper/onet-codes.csv")
    stub_request(:get, /www.onetonline.org./)
      .to_return(status: 200, body: file.read, headers: {})
  end
end
