require "rails_helper"

RSpec.describe Scraper::NewYorkJob, type: :job do
  describe "#perform" do
    context "when files have not been downloaded previously" do
      it "downloads pdf files to a standards import record" do
        stub_responses
        expect {
          described_class.new.perform
        }.to change(StandardsImport, :count).by(7)

        standards_import = StandardsImport.last
        expect(standards_import.files.count).to eq 1
        expect(standards_import.name).to eq "https://dol.ny.gov/system/files/documents/2022/06/cnc-tool-and-cutter-grinder-time.pdf"
        expect(standards_import.notes).to eq "From Scraper::NewYorkJob: https://dol.ny.gov/apprenticeship/apprenticeship-trades"
      end
    end

    context "when some files have been downloaded previously" do
      it "downloads new pdf files to a standards import record" do
        old_standards_import = create(:standards_import, :with_files, name: "https://dol.ny.gov/system/files/documents/2022/06/cnc-tool-and-cutter-grinder-time.pdf")
        stub_responses
        expect {
          described_class.new.perform
        }.to change(StandardsImport, :count).by(6)

        standards_import = StandardsImport.last
        expect(standards_import.files.count).to eq 1

        expect(old_standards_import.reload.files.count).to eq 1
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
