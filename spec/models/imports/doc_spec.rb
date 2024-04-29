require "rails_helper"

RSpec.describe Imports::Doc, type: :model do
  it_behaves_like "an imported file"

  describe "#process" do
    it "attaches a PDF to the Doc" do
      allow(ConvertDocToPdf).to receive(:call).and_return(
        Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf")
      )
      doc = create(:imports_doc, public_document: true)

      doc.process
      doc.reload

      expect(doc.pdf).to be_present
      pdf = doc.pdf
      expect(pdf.status).to eq("completed")
      expect(pdf.public_document).to eq(true)
      expect(pdf.courtesy_notification).to eq("not_required")

      expect(doc.processed_at).to be_present
      expect(doc.processing_errors).to be_blank
      expect(doc.status).to eq("archived")
    end

    it "updates the Doc for missing soffice" do
      allow(ConvertDocToPdf).to receive(:call).and_raise(ConvertDocToPdf::PdfConversionError)
      doc = create(:imports_doc)

      expect { doc.process }.to raise_error(ConvertDocToPdf::PdfConversionError)
      doc.reload

      expect(doc.pdf).to be_blank
      expect(doc.processed_at).to be_blank
      expect(doc.processing_errors).to be_present
      expect(doc.status).to eq("needs_backend_support")
    end

    it "processes the PDF" do
      allow(ConvertDocToPdf).to receive(:call).and_return(
        Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf")
      )
      pdf_import = double(:pdf, process: nil)
      doc = create(:imports_doc)
      allow(doc).to receive(:pdf).and_return(pdf_import)

      doc.process(arg: 1)

      expect(pdf_import).to have_received(:process).with(arg: 1)
    end
  end
end
