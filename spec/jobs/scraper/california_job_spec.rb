require "rails_helper"

RSpec.describe Scraper::CaliforniaJob, type: :job do
  describe "#perform" do
    it "downloads pdf files to an standards import record" do
      stub_responses
      expect {
        described_class.new.perform
      }.to change(StandardsImport, :count).by(1)

      standard_import = StandardsImport.last
      expect(standard_import.files.count).to be > 0
    end
  end

  def stub_responses
    html_file = file_fixture("scraper/california.htm")
    stub_request(:get, /dir.ca.gov.*\.htm/).
      to_return(status: 200, body: html_file.read, headers: {})

    pdf_file = file_fixture("pixel1x1.pdf")
    stub_request(:get, /dir.ca.gov.*\.pdf/).
      to_return(status: 200, body: pdf_file.read, headers: {})
  end
end
