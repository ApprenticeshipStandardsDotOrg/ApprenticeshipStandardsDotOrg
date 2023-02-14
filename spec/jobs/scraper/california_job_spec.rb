require "rails_helper"

RSpec.describe Scraper::CaliforniaJob, type: :job do
  describe "#perform" do
    context "when files have not been downloaded previously" do
      it "downloads pdf files to a standards import record" do
        stub_responses
        expect {
          described_class.new.perform
        }.to change(StandardsImport, :count).by(6)

        standard_import = StandardsImport.last
        expect(standard_import.files.count).to eq 1
        expect(standard_import.name).to eq "https://www.dir.ca.gov/das/standards/101015_SB%20ECE_Standards.pdf"
        expect(standard_import.organization).to eq "Santa Barbara County Education Office (SBCEO) Early Childhood Educator Apprenticeship Program"
        expect(standard_import.notes).to eq "From Scraper::CaliforniaJob: https://www.dir.ca.gov/das/ProgramStandards.htm"
      end
    end

    context "when some files have been downloaded previously" do
      it "downloads new pdf files to a standards import record" do
        create(:standards_import, name: "https://www.dir.ca.gov/das/standards/100859_SETA%20ECE_Standards.pdf", organization: "Sacramento Employment and Training Agency (SETA) Early Childhood Education Apprenticeship Program")
        stub_responses
        expect {
          described_class.new.perform
        }.to change(StandardsImport, :count).by(5)

        standard_import = StandardsImport.last
        expect(standard_import.files.count).to eq 1
      end
    end
  end

  def stub_responses
    html_file = file_fixture("scraper/california.htm")
    stub_request(:get, /dir.ca.gov.*\.htm/)
      .to_return(status: 200, body: html_file.read, headers: {})

    pdf_file = file_fixture("pixel1x1.pdf")
    stub_request(:get, /dir.ca.gov.*\.pdf/)
      .to_return(status: 200, body: pdf_file.read, headers: {})
  end
end
