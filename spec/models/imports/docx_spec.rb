require "rails_helper"

RSpec.describe Imports::Docx, type: :model do
  it_behaves_like "an imported file"

  describe "#process" do
    it "attaches a PDF to the Docx" do
      pdf_path = Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf")
      allow(ConvertDocToPdf).to receive(:call).and_return(pdf_path)
      docx = create(:imports_docx, public_document: true)

      docx.process
      docx.reload

      expect(docx.pdf).to be_present
      pdf = docx.pdf
      expect(pdf.status).to eq("pending")
      expect(pdf.public_document).to eq(true)
      expect(pdf.courtesy_notification).to eq("not_required")

      expect(docx.processed_at).to be_present
      expect(docx.processing_errors).to be_blank
      expect(docx.status).to eq("archived")
    end

    it "updates the Docx for missing soffice" do
      allow(ConvertDocToPdf).to receive(:call).and_raise(ConvertDocToPdf::PdfConversionError)
      docx = create(:imports_docx)

      expect { docx.process }.to raise_error(ConvertDocToPdf::PdfConversionError)
      docx.reload

      expect(docx.pdf).to be_blank
      expect(docx.processed_at).to be_blank
      expect(docx.processing_errors).to be_present
      expect(docx.status).to eq("needs_backend_support")
    end

    it "processes the PDF" do
      allow(ConvertDocToPdf).to receive(:call).and_return(
        Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf")
      )
      pdf_import = double(:pdf, process: nil)
      docx = create(:imports_docx)
      allow(docx).to receive(:pdf).and_return(pdf_import)

      docx.process(arg: 1)

      expect(pdf_import).to have_received(:process).with(arg: 1)
    end
  end

  describe "#root" do
    it "retrieves the standards_import at the root" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)
      docx_listing = create(:imports_docx_listing, parent: uncat)
      docx = create(:imports_docx, parent: docx_listing)

      expect(docx.root).to eq standards_import
    end
  end
end
