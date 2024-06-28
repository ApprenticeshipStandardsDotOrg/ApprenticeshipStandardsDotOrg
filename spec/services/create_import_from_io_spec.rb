require "rails_helper"

RSpec.describe CreateImportFromIo do
  describe "#call" do
    context "when file has not been attached previously" do
      it "returns an Imports::Pdf object" do
        allow(ConvertDocToPdf).to receive(:call).and_return(file_fixture("pixel1x1.pdf"))

        filename = "document.doc"
        io = File.open(file_fixture(filename))

        import = described_class.call(
          io: io,
          filename: filename,
          title: "Specialist",
          notes: "Some notes",
          source: "Some source URL",
          metadata: {date: "01/11/2023"}
        )

        expect(import).to be_a(Imports::Pdf)
      end

      it "attaches file to a standards import record and creates an Uncategorized Import child" do
        allow(ConvertDocToPdf).to receive(:call).and_return(file_fixture("pixel1x1.pdf"))

        filename = "document.doc"
        io = File.open(file_fixture(filename))

        expect {
          described_class.call(
            io: io,
            filename: filename,
            title: "Specialist",
            notes: "Some notes",
            source: "Some source URL",
            metadata: {date: "01/11/2023"}
          )
        }.to change(StandardsImport, :count).by(1)
          .and change(Imports::Uncategorized, :count).by(1)
          .and change(Imports::Doc, :count).by(1)
          .and change(Imports::Pdf, :count).by(1)
          .and change(ActiveStorage::Attachment, :count).by(4)
          .and change(ActiveStorage::Blob, :count).by(2)

        standards_import = StandardsImport.last
        expect(standards_import.files.count).to eq 1
        expect(standards_import.name).to eq "document.doc"
        expect(standards_import.organization).to eq "Specialist"
        expect(standards_import.notes).to eq "Some notes"
        expect(standards_import.public_document).to be true
        expect(standards_import.source_url).to eq "Some source URL"
        expect(standards_import.metadata).to eq({"date" => "01/11/2023"})

        import = Imports::Uncategorized.last
        expect(import.metadata).to eq({"date" => "01/11/2023"})
        expect(import.file.attached?).to be_truthy
        expect(import.file.blob.filename.to_s).to eq "document.doc"
        expect(import.parent).to eq standards_import
        expect(import.status).to eq "archived"

        pdf = Imports::Pdf.last
        expect(pdf.metadata).to eq({"date" => "01/11/2023"})
        expect(pdf.file.attached?).to be_truthy
        expect(pdf.file.blob.filename.to_s).to eq "pixel1x1.pdf"
        expect(pdf.parent).to eq Imports::Doc.last
        expect(pdf.status).to eq "pending"
      end
    end
  end

  context "when file has been attached previously" do
    it "returns nil" do
      filename = "document.doc"
      io = File.open(file_fixture(filename))

      create(:standards_import,
        :with_files,
        name: "document.doc",
        organization: "Specialist")

      result = described_class.call(
        io: io,
        filename: filename,
        title: "Specialist",
        notes: "Some notes",
        source: "Some source URL",
        metadata: {date: "01/11/2023"}
      )

      expect(result).to be_nil
    end

    it "does not create new StandardsImport or Import record" do
      filename = "document.doc"
      io = File.open(file_fixture(filename))

      create(:standards_import,
        :with_files,
        name: "document.doc",
        organization: "Specialist")

      expect {
        described_class.call(
          io: io,
          filename: filename,
          title: "Specialist",
          notes: "Some notes",
          source: "Some source URL",
          metadata: {date: "01/11/2023"}
        )
      }.to change(StandardsImport, :count).by(0)
        .and change(Imports::Uncategorized, :count).by(0)
        .and change(ActiveStorage::Attachment, :count).by(0)
        .and change(ActiveStorage::Blob, :count).by(0)
    end
  end
end
