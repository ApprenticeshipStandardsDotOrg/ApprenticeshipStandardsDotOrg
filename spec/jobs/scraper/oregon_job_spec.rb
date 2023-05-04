require "rails_helper"

RSpec.describe Scraper::OregonJob, type: :job do
  xdescribe "#perform" do
    # Skipping until we know how to mock the browser effectively
    context "when files have not been downloaded previously" do
      it "downloads pdf files to a standards import record" do
        # stub_responses
        js_doc = file_fixture("scraper/oregon.html").read
        element = double("element", wait_until: js_doc)
        browser_mock = instance_double("Watir::Browser", goto: nil, element: element)
        allow(Watir::Browser).to receive(:new).and_return(browser_mock)
        browser_mock.close
        html_file = file_fixture("scraper/oregon.html")
        html_body = Nokogiri::HTML(html_file)
        expect {
          described_class.new.perform(html_body)
        }.to change(StandardsImport, :count).by(85)

        standard_import = StandardsImport.last
        expect(standard_import.files.count).to eq 1
        expect(standard_import.public_document).to be true
      end
    end

    xcontext "when some files have been downloaded previously" do
      it "downloads new pdf files to a standards import record" do
        create(:standards_import, name: "https://www.oregon.gov/boli/apprenticeship/Standards/1023_0284.0.pdf", organization: "PORTLAND OUTSIDE ELECTRICAL WORKERS TATC")
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
    html_file = file_fixture("scraper/oregon.html")
    stub_request(:get, /oregon.gov.*/)
      .to_return(status: 200, body: html_file.read, headers: {})

    pdf_file = file_fixture("pixel1x1.pdf")
    stub_request(:get, /oregon.gov.*\.pdf/)
      .to_return(status: 200, body: pdf_file.read, headers: {})
  end
end
