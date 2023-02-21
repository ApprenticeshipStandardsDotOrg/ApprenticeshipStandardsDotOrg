require "rails_helper"

RSpec.describe Scraper::OregonJob, type: :job do
  describe "#perform" do
    context "when files have not been downloaded previously" do
      it "downloads pdf files to a standards import record" do
        stub_responses
        expect {
          described_class.new.perform
        }.to change(StandardsImport, :count).by(85)

        standard_import = StandardsImport.last
        expect(standard_import.files.count).to eq 1
      end
    end

    context "when some files have been downloaded previously" do
      it "downloads new pdf files to a standards import record" do
        create(:standards_import, name: "https://www.oregon.gov/boli/apprenticeship/Standards/5035_0005.0.pdf", organization: "SOUTHERN OREGON AVIATION JATC")
        stub_responses
        expect {
          described_class.new.perform
        }.to change(StandardsImport, :count).by(84)

        standard_import = StandardsImport.last
        expect(standard_import.files.count).to eq 1
      end
    end
  end

  def stub_responses
    html_file = file_fixture("scraper/oregon.aspx")
    stub_request(:get, /oregon.gov.*/)
      .to_return(status: 200, body: html_file.read, headers: {})

    pdf_file = file_fixture("pixel1x1.pdf")
    stub_request(:get, /oregon.gov.*\.pdf/)
      .to_return(status: 200, body: pdf_file.read, headers: {})
  end
end
