require "rails_helper"

RSpec.describe Scraper::AppreticeshipBulletinsJob, type: :job do
  describe "#perform" do
    context "when files have not been downloaded previously" do
      context "when file has attachments" do
        it "downloads docx files to a standards import record" do
          stub_responses
          expect {
            described_class.new.perform
          }.to change(StandardsImport, :count).by(3)

          standard_import = StandardsImport.last
          expect(standard_import.files.count).to eq 1
          expect(standard_import.name).to eq "https://www.apprenticeship.gov/sites/default/files/bulletins/Bulletin%202023-50%20New%20NOF%20Appren%20Occ%20Jr%20Cloud%20Engineer.docx"
          expect(standard_import.organization).to eq "2023-50"
          expect(standard_import.notes).to eq "From Scraper::AppreticeshipBulletinsJob #{Scraper::AppreticeshipBulletinsJob::BULLETIN_LIST_URL}"
        end
      end

      context "when file does not have attachments" do
        it "ignores the file" do
          stub_responses_for_file_without_attachments
          expect {
            described_class.new.perform
          }.to_not change(StandardsImport, :count)

          expect(StandardsImport.last).to be_nil
        end
      end
    end

    context "when some files have been downloaded previously" do
      it "downloads new docx files to a standards import record" do
        create(:standards_import,
          name: "https://www.apprenticeship.gov/sites/default/files/bulletins/Bulletin%202023-50%20New%20NOF%20Appren%20Occ%20Jr%20Cloud%20Engineer.docx",
          organization: "2023-50")
        stub_responses
        expect {
          described_class.new.perform
        }.to change(StandardsImport, :count).by(2)

        standard_import = StandardsImport.last
        expect(standard_import.files.count).to eq 1
      end
    end
  end

  def stub_responses
    bulletin_document = file_fixture("scraper/bulletins-results.csv")
    stub_request(:get, Scraper::AppreticeshipBulletinsJob::BULLETIN_LIST_URL)
      .to_return(status: 200, body: bulletin_document.read, headers: {})

    first_bulletin = file_fixture("scraper/bulletins/Bulletin 2023-52 New NGS AFSA.docx")
    stub_request(:get, /Bulletin%202023-52%20New%20NGS%20AFSA.docx/)
      .to_return(status: 200, body: first_bulletin, headers: {"Content-Type": Scraper::AppreticeshipBulletinsJob::DOCX_CONTENT_TYPE})

    second_bulletin = file_fixture("scraper/bulletins/Bulletin 2023-51 New Appren Occ Appraisal and Valuation of Real Property.docx")
    stub_request(:get, /Bulletin%202023-51%20New%20Appren%20Occ%20Appraisal%20and%20Valuation%20of%20Real%20Property.docx/)
      .to_return(status: 200, body: second_bulletin, headers: {"Content-Type": Scraper::AppreticeshipBulletinsJob::DOCX_CONTENT_TYPE})

    third_bulletin = file_fixture("scraper/bulletins/Bulletin 2023-50 New NOF Appren Occ Jr Cloud Engineer.docx")
    stub_request(:get, /Bulletin%202023-50%20New%20NOF%20Appren%20Occ%20Jr%20Cloud%20Engineer.docx/)
      .to_return(status: 200, body: third_bulletin, headers: {"Content-Type": Scraper::AppreticeshipBulletinsJob::DOCX_CONTENT_TYPE})
  end

  def stub_responses_for_file_without_attachments
    bulletin_document = file_fixture("scraper/bulletins-results-without-attachments.csv")
    stub_request(:get, Scraper::AppreticeshipBulletinsJob::BULLETIN_LIST_URL)
      .to_return(status: 200, body: bulletin_document.read, headers: {})

    first_bulletin = file_fixture("scraper/bulletins/Bulletin 2023-46 ManpowerGroup Rev Appendix A.docx")
    stub_request(:get, /Bulletin%202023-46%20ManpowerGroup%20Rev%20Appendix%20A.docx/)
      .to_return(status: 200, body: first_bulletin, headers: {"Content-Type": Scraper::AppreticeshipBulletinsJob::DOCX_CONTENT_TYPE})
  end
end
