require "rails_helper"

RSpec.describe Scraper::ApprenticeshipBulletinsJob, type: :job do
  describe "#perform" do
    context "when files have not been downloaded previously" do
      it "downloads any file to a standards import record" do
        stub_responses
        expect(Scraper::ExportFileAttachmentsJob).to receive(:perform_later).with(kind_of(SourceFile)).exactly(6).times
        perform_enqueued_jobs do
          expect {
            described_class.new.perform
          }.to change(StandardsImport, :count).by(6)
        end

        standard_import = StandardsImport.last
        expect(standard_import.files.count).to eq 1
        expect(standard_import.name).to eq "https://www.apprenticeship.gov/sites/default/files/bulletins/Bulletin_2016-22.pdf"
        expect(standard_import.organization).to eq "Wildland Fire Fighter Specialist"
        expect(standard_import.notes).to eq "From Scraper::ApprenticeshipBulletinsJob"
        expect(standard_import.public_document).to be true
        expect(standard_import.source_url).to eq Scraper::ApprenticeshipBulletinsJob::BULLETIN_LIST_URL

        source_file = SourceFile.last
        expect(source_file.metadata).to eq({"date" => "03/11/16"})
      end
    end
  end

  context "when some files have been downloaded previously" do
    it "downloads any new file to a standards import record" do
      old_import = create(:standards_import, :with_files,
        name: "https://www.apprenticeship.gov/sites/default/files/bulletins/Bulletin_2016-22.pdf",
        organization: "Wildland Fire Fighter Specialist")
      stub_responses
      expect(Scraper::ExportFileAttachmentsJob).to receive(:perform_later).with(kind_of(SourceFile)).exactly(5).times
      perform_enqueued_jobs do
        expect {
          described_class.new.perform
        }.to change(StandardsImport, :count).by(5)
      end

      standard_import = StandardsImport.last
      expect(standard_import.files.count).to eq 1

      source_file = SourceFile.last
      expect(source_file.metadata).to eq({"date" => "03/01/22"})

      expect(old_import.reload.files.count).to eq 1
    end
  end

  def stub_responses
    bulletin_document = file_fixture("scraper/bulletins-results.csv")
    stub_request(:get, Scraper::ApprenticeshipBulletinsJob::BULLETIN_LIST_URL)
      .to_return(status: 200, body: bulletin_document.read, headers: {})

    first_docx_bulletin_with_attachments = file_fixture("scraper/bulletins/Bulletin 2023-52 New NGS AFSA.docx")
    stub_request(:get, /Bulletin%202023-52%20New%20NGS%20AFSA.docx/)
      .to_return(status: 200, body: first_docx_bulletin_with_attachments)

    second_docx_bulletin_with_attachments = file_fixture("scraper/bulletins/Bulletin 2023-51 New Appren Occ Appraisal and Valuation of Real Property.docx")
    stub_request(:get, /Bulletin%202023-51%20New%20Appren%20Occ%20Appraisal%20and%20Valuation%20of%20Real%20Property.docx/)
      .to_return(status: 200, body: second_docx_bulletin_with_attachments)

    third_docx_bulletin_with_attachments = file_fixture("scraper/bulletins/Bulletin 2023-50 New NOF Appren Occ Jr Cloud Engineer.docx")
    stub_request(:get, /Bulletin%202023-50%20New%20NOF%20Appren%20Occ%20Jr%20Cloud%20Engineer.docx/)
      .to_return(status: 200, body: third_docx_bulletin_with_attachments)

    docx_bulletin_without_attachments = file_fixture("scraper/bulletins/Bulletin 2023-46 ManpowerGroup Rev Appendix A.docx")
    stub_request(:get, /Bulletin%202023-46%20ManpowerGroup%20Rev%20Appendix%20A.docx/)
      .to_return(status: 200, body: docx_bulletin_without_attachments)

    doc_bulletin = file_fixture("scraper/bulletins/Bulletin-2022-58.doc")
    stub_request(:get, /Bulletin-2022-58.doc/)
      .to_return(status: 200, body: doc_bulletin)

    pdf_bulletin = file_fixture("scraper/bulletins/Bulletin_2016-22.pdf")
    stub_request(:get, /Bulletin_2016-22.pdf/)
      .to_return(status: 200, body: pdf_bulletin)
  end
end
