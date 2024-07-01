require "rails_helper"

RSpec.describe CreateImportFromUri do
  describe "#call" do
    context "when file has not been downloaded previously" do
      it "downloads file to a standards import record and creates an Uncategorized Import child" do
        stub_responses

        file_uri = "https://www.apprenticeship.gov/sites/default/files/bulletins/Bulletin%202023-52%20New%20NGS%20AFSA.docx"

        expect_any_instance_of(Imports::Uncategorized).to receive(:process).with(listing: true)

        expect {
          described_class.call(
            uri: file_uri,
            title: "Specialist",
            notes: "Some notes",
            source: "Some source URL",
            listing: true,
            metadata: {date: "01/11/2023"}
          )
        }.to change(StandardsImport, :count).by(1)
          .and change(Imports::Uncategorized, :count).by(1)
          .and change(ActiveStorage::Attachment, :count).by(1)
          .and change(ActiveStorage::Blob, :count).by(1)

        standards_import = StandardsImport.last
        expect(standards_import.name).to eq file_uri
        expect(standards_import.organization).to eq "Specialist"
        expect(standards_import.notes).to eq "Some notes"
        expect(standards_import.public_document).to be true
        expect(standards_import.source_url).to eq "Some source URL"
        expect(standards_import.metadata).to eq({"date" => "01/11/2023"})

        import = Imports::Uncategorized.last
        expect(import.metadata).to eq({"date" => "01/11/2023"})
        expect(import.file.attached?).to be_truthy
        expect(import.file.blob.filename.to_s).to eq "Bulletin 2023-52 New NGS AFSA.docx"
        expect(import.parent).to eq standards_import
        expect(import.status).to eq "unfurled"
      end
    end
  end

  context "when file has been downloaded previously" do
    it "does not create new StandardsImport or Import record" do
      stub_responses

      file_uri = "https://www.apprenticeship.gov/sites/default/files/bulletins/Bulletin%202023-52%20New%20NGS%20AFSA.docx"

      create(:standards_import,
        name: file_uri,
        organization: "Specialist")

      expect {
        described_class.call(
          uri: file_uri,
          title: "Specialist",
          notes: "Some notes",
          source: "Some source URL",
          listing: true,
          metadata: {date: "01/11/2023"}
        )
      }.to change(StandardsImport, :count).by(0)
        .and change(Imports::Uncategorized, :count).by(0)
        .and change(ActiveStorage::Attachment, :count).by(0)
        .and change(ActiveStorage::Blob, :count).by(0)
    end
  end

  def stub_responses
    file = file_fixture("scraper/bulletins/Bulletin 2023-52 New NGS AFSA.docx")
    stub_request(:get, /Bulletin%202023-52%20New%20NGS%20AFSA.docx/)
      .to_return(status: 200, body: file)
  end
end
