require "rails_helper"

RSpec.describe ScrapeOnetCodes do
  describe "#call" do
    it "creates onet records" do
      stub_responses
      onet = create(:onet, name: "Actuaries", code: "1234.56")

      expect {
        described_class.new.call
      }.to change(Onet, :count).by(2)

      onet.reload
      expect(onet.name).to eq "Actuaries"
      expect(onet.code).to eq "15-2011.00"

      onet1 = Onet.second
      expect(onet1.name).to eq "Accountants and Auditors"
      expect(onet1.code).to eq "13-2011.00"

      onet2 = Onet.third
      expect(onet2.name).to eq "Actors"
      expect(onet2.code).to eq "27-2011.00"
    end
  end

  def stub_responses
    file = file_fixture("scraper/onet-codes.csv")
    stub_request(:get, /www.onetonline.org./)
      .to_return(status: 200, body: file.read, headers: {})
  end
end
