require "rails_helper"

RSpec.describe Scraper::NewYorkJob, type: :job do
  describe "#perform" do
    context "when files have not been downloaded previously" do
      it "creates a standards import record with imports" do
        stub_responses
        expect {
          described_class.new.perform
        }.to change(StandardsImport, :count).by(7)
          .and change(Imports::Uncategorized, :count).by(7)
          .and change(Imports::Pdf, :count).by(7)

        standards_import = StandardsImport.last
        expect(standards_import.name).to eq "https://dol.ny.gov/system/files/documents/2022/06/cnc-tool-and-cutter-grinder-time.pdf"
        expect(standards_import.notes).to eq "From Scraper::NewYorkJob"
        expect(standards_import.public_document).to be true
        expect(standards_import.source_url).to eq "https://dol.ny.gov/apprenticeship/apprenticeship-trades"
      end
    end

    context "when some files have been downloaded previously" do
      it "creates standards import records for new files only" do
        name = "https://dol.ny.gov/system/files/documents/2022/06/cnc-tool-and-cutter-grinder-time.pdf"
        old_standards_import = create(:standards_import, name: name, organization: name)
        stub_responses
        expect {
          described_class.new.perform
        }.to change(StandardsImport, :count).by(6)
          .and change(Imports::Uncategorized, :count).by(6)
          .and change(Imports::Pdf, :count).by(6)
      end
    end
  end

  def stub_responses
    html_file = file_fixture("scraper/new_york.htm")
    stub_request(:get, /dol.ny.gov\/apprenticeship*/)
      .to_return(status: 200, body: html_file.read, headers: {})
    pdf_file = file_fixture("pixel1x1.pdf")
    stub_request(:get, /dol.ny.gov\/system*/)
      .to_return(status: 200, body: pdf_file.read, headers: {})
  end
end
