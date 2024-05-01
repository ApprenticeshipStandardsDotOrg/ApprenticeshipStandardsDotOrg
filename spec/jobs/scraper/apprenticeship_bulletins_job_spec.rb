require "rails_helper"

RSpec.describe Scraper::ApprenticeshipBulletinsJob, type: :job do
  describe "#perform" do
    it "calls ProcessApprenticeshipBulletin service for each row in csv file" do
      stub_responses

      expect(ProcessApprenticeshipBulletin).to receive(:call).with(
        file_uri: "https://www.apprenticeship.gov/sites/default/files/bulletins/Bulletin%202023-52%20New%20NGS%20AFSA.docx",
        title: "2023-52",
        date: "01/11/2023"
      )
      expect(ProcessApprenticeshipBulletin).to receive(:call).with(
        file_uri: "https://www.apprenticeship.gov/sites/default/files/bulletins/Bulletin_2016-22.pdf",
        title: "Wildland Fire Fighter Specialist",
        date: "03/11/16"
      )

      described_class.new.perform
    end
  end

  def stub_responses
    bulletin_document = file_fixture("scraper/bulletins-results.csv")
    stub_request(:get, Scraper::ApprenticeshipBulletinsJob::BULLETIN_LIST_URL)
      .to_return(status: 200, body: bulletin_document.read, headers: {})
  end
end
