require "rails_helper"

RSpec.describe Imports::DocxListing, type: :model do
  it_behaves_like "an imported file"

  describe "#process" do
    it "creates imports for each attachment" do
      allow(ConvertDocToPdf).to receive(:call).and_return(
        Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf")
      )
      docx_listing = create(
        :imports_docx_listing,
        file: Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "docx_file_attachments.docx"))
      )

      docx_listing.process
      docx_listing.reload

      expect(docx_listing.imports.count).to eq(7)
      docx_listing.imports.each do |import|
        expect(import.status).to eq("archived")
        expect(import).to be_an(Imports::Uncategorized)
      end
    end

    it "processes its imports" do
      allow(ConvertDocToPdf).to receive(:call).and_return(
        Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf")
      )
      imports = [double(:uncategorized, process: nil)]
      docx_listing = create(:imports_docx_listing)
      allow(DocxListingSplitter).to receive(:split)
      allow(docx_listing).to receive(:imports).and_return(imports)

      docx_listing.process(arg: 1)

      expect(imports[0]).to have_received(:process).with(arg: 1)
    end

    it "marks itself as processed" do
      allow(ConvertDocToPdf).to receive(:call).and_return(
        Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf")
      )
      docx_listing = create(
        :imports_docx_listing,
        file: Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "docx_file_attachments.docx"))
      )

      docx_listing.process
      docx_listing.reload

      expect(docx_listing.processed_at).to be_present
      expect(docx_listing.processing_errors).to be_blank
      expect(docx_listing.status).to eq("archived")
    end

    it "tracks errors" do
      allow(ConvertDocToPdf).to receive(:call).and_raise(Zip::Error)
      docx_listing = create(
        :imports_docx_listing,
        file: Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "oleObject1.bin"))
      )

      expect { docx_listing.process }.to raise_error(Zip::Error)
      docx_listing.reload

      expect(docx_listing.processed_at).to be_blank
      expect(docx_listing.processing_errors).to be_present
      expect(docx_listing.status).to eq("needs_backend_support")
    end
  end

  describe "#import_root" do
    it "retrieves the standards_import at the root" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)
      docx_listing = create(:imports_docx_listing, parent: uncat)

      expect(docx_listing.import_root).to eq standards_import
    end
  end

  describe "#pdf_leaf" do
    it "raises a not implemented error" do
      docx_listing = create(:imports_docx_listing)

      expect{
        docx_listing.pdf_leaf
      }.to raise_error(NoMethodError, "Imports::DocxListing records do not have a PDF leaf")
    end
  end
end
