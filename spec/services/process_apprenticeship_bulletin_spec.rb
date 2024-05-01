require "rails_helper"

RSpec.describe ProcessApprenticeshipBulletin do
  describe "#call" do
    it "downloads file to a standards import record and creates an Uncategorized Import child" do
      stub_responses

      encoded_filename = "Bulletin%202023-52%20New%20NGS%20AFSA.docx"
      file_uri = "https://www.apprenticeship.gov/sites/default/files/bulletins/#{encoded_filename}"

      expect_any_instance_of(Imports::Uncategorized).to receive(:process)

      expect {
        described_class.call(
          file_uri: file_uri, title: "Specialist", date: "01/11/2023"
        )
      }.to change(StandardsImport, :count).by(1)
        .and change(Imports::Uncategorized, :count).by(1)
        .and change(ActiveStorage::Attachment, :count).by(2)
        .and change(ActiveStorage::Blob, :count).by(1)

      standards_import = StandardsImport.last
      expect(standards_import.files.count).to eq 1
      expect(standards_import.name).to eq "https://www.apprenticeship.gov/sites/default/files/bulletins/#{encoded_filename}"
      expect(standards_import.organization).to eq "Specialist"
      expect(standards_import.notes).to eq "From Scraper::ApprenticeshipBulletinsJob"
      expect(standards_import.public_document).to be true
      expect(standards_import.source_url).to eq Scraper::ApprenticeshipBulletinsJob::BULLETIN_LIST_URL
      expect(standards_import).to be_bulletin # bulletin field to be removed but leaving for now to help with production verification
      expect(standards_import.metadata).to eq({"date" => "01/11/2023"})

      import = Imports::Uncategorized.last
      expect(import.metadata).to eq({"date" => "01/11/2023"})
      expect(import.file.attached?).to be_truthy
      expect(import.file.blob.filename.to_s).to eq "Bulletin 2023-52 New NGS AFSA.docx"
      expect(import.parent).to eq standards_import
    end
  end

  def stub_responses
    docx_bulletin_with_attachments = file_fixture("scraper/bulletins/Bulletin 2023-52 New NGS AFSA.docx")
    stub_request(:get, /Bulletin%202023-52%20New%20NGS%20AFSA.docx/)
      .to_return(status: 200, body: docx_bulletin_with_attachments)
  end
end
