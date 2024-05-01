require "rails_helper"

RSpec.describe Scraper::ApprenticeshipBulletinsJob, type: :job do
  describe "#perform" do
    context "when files have not been downloaded previously" do
      it "downloads files to a standards import record and creates an Uncategorized Import child" do
        stub_responses

        expect_any_instance_of(Imports::Uncategorized).to receive(:process)
        allow_any_instance_of(Imports::Uncategorized).to receive(:process).and_return(nil)

        expect {
          described_class.new.perform
        }.to change(StandardsImport, :count).by(6)
          .and change(Imports::Uncategorized, :count).by(6)
          .and change(ActiveStorage::Attachment, :count).by(12)
          .and change(ActiveStorage::Blob, :count).by(6)

        standards_import1 = StandardsImport.first
        expect(standards_import1.files.count).to eq 1
        encoded_filename = URI.encode_uri_component("Bulletin 2023-52 New NGS AFSA.docx")
        expect(standards_import1.name).to eq "https://www.apprenticeship.gov/sites/default/files/bulletins/#{encoded_filename}"
        expect(standards_import1.organization).to eq "2023-52"
        expect(standards_import1.notes).to eq "From Scraper::ApprenticeshipBulletinsJob"
        expect(standards_import1.public_document).to be true
        expect(standards_import1.source_url).to eq Scraper::ApprenticeshipBulletinsJob::BULLETIN_LIST_URL
        expect(standards_import1).to be_bulletin # bulletin field to be removed but leaving for now to help with production verification
        expect(standards_import1.metadata).to eq({"date" => "01/11/2023"})

        standards_import6 = StandardsImport.last
        expect(standards_import6.files.count).to eq 1
        expect(standards_import6.name).to eq "https://www.apprenticeship.gov/sites/default/files/bulletins/Bulletin_2016-22.pdf"
        expect(standards_import6.organization).to eq "Wildland Fire Fighter Specialist"
        expect(standards_import6.notes).to eq "From Scraper::ApprenticeshipBulletinsJob"
        expect(standards_import6.public_document).to be true
        expect(standards_import6.source_url).to eq Scraper::ApprenticeshipBulletinsJob::BULLETIN_LIST_URL
        expect(standards_import6).to be_bulletin # bulletin field to be removed but leaving for now to help with production verification
        expect(standards_import6.metadata).to eq({"date" => "03/11/16"})

        import1 = Imports::Uncategorized.first
        expect(import1.metadata).to eq({"date" => "01/11/2023"})
        expect(import1.file.attached?).to be_truthy
        puts standards_import1.files.first.blob.filename
        expect(import1.file.blob.filename.to_s).to eq "Bulletin 2023-52 New NGS AFSA.docx"
        expect(import1.parent).to eq standards_import1

        import6 = Imports::Uncategorized.last
        expect(import6.metadata).to eq({"date" => "03/11/16"})
        expect(import6.file.attached?).to be_truthy
        expect(import6.file.blob.filename.to_s).to eq "Bulletin_2016-22.pdf"
        expect(import6.parent).to eq standards_import6
      end
    end
  end

  context "when some files have been downloaded previously" do
    it "downloads any new file to a standards import record" do
      stub_responses

      old_import = create(:standards_import, :with_files,
        name: "https://www.apprenticeship.gov/sites/default/files/bulletins/Bulletin_2016-22.pdf",
        organization: "Wildland Fire Fighter Specialist")

      allow_any_instance_of(Imports::Uncategorized).to receive(:process).and_return(nil)

      expect {
        described_class.new.perform
      }.to change(StandardsImport, :count).by(5)
        .and change(Imports::Uncategorized, :count).by(5)

      standards_import = StandardsImport.last
      expect(standards_import.files.count).to eq 1

      import = Imports::Uncategorized.last
      expect(import.metadata).to eq({"date" => "03/01/22"})
      expect(import.parent).to eq standards_import

      expect(old_import.reload.files.count).to eq 1
    end
  end

  def stub_responses
    bulletin_document = file_fixture("scraper/bulletins-results.csv")
    stub_request(:get, Scraper::ApprenticeshipBulletinsJob::BULLETIN_LIST_URL)
      .to_return(status: 200, body: bulletin_document.read, headers: {})

    docx_bulletin_with_attachments = file_fixture("scraper/bulletins/Bulletin 2023-52 New NGS AFSA.docx")
    stub_request(:get, /Bulletin%202023-52%20New%20NGS%20AFSA.docx/)
      .to_return(status: 200, body: first_docx_bulletin_with_attachments)

    pdf_bulletin = file_fixture("scraper/bulletins/Bulletin_2016-22.pdf")
    stub_request(:get, /Bulletin_2016-22.pdf/)
      .to_return(status: 200, body: pdf_bulletin)
  end
end
