require "rails_helper"

RSpec.describe Imports::Docx, type: :model do
  it_behaves_like "an imported file"

  describe "#process" do
    it "attaches a PDF to the Docx" do
      pdf_path = Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf")
      allow(ConvertDocToPdf).to receive(:call).and_return(pdf_path)
      assignee = create(:user, :converter)
      docx = create(:imports_docx, public_document: true, courtesy_notification: :pending, assignee: assignee)

      docx.process
      docx.reload

      expect(docx.pdf).to be_present
      pdf = docx.pdf
      expect(pdf.status).to eq("pending")
      expect(pdf.public_document).to eq(true)
      expect(pdf.courtesy_notification).to eq("pending")
      expect(pdf.assignee).to eq assignee

      expect(docx.processed_at).to be_present
      expect(docx.processing_errors).to be_blank
      expect(docx.status).to eq("archived")
    end

    it "updates the Docx for missing soffice" do
      allow(ConvertDocToPdf).to receive(:call).and_raise(ConvertDocToPdf::PdfConversionError)
      docx = create(:imports_docx)

      expect_any_instance_of(ErrorSubscriber).to receive(:report).with(kind_of(ConvertDocToPdf::PdfConversionError), hash_including(context: {import_id: docx.id}, severity: :error)).and_call_original
      docx.process
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

  describe "#import_root" do
    it "retrieves the standards_import at the root" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)
      docx_listing = create(:imports_docx_listing, parent: uncat)
      docx = create(:imports_docx, parent: docx_listing)

      expect(docx.import_root).to eq standards_import
    end
  end

  describe "#docx_listing_root" do
    it "when descended from bulletin, retrieves the docx_listing ancestor" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)
      docx_listing = create(:imports_docx_listing, parent: uncat)
      uncat2 = create(:imports_uncategorized, parent: docx_listing)
      docx = create(:imports_docx, parent: uncat2)

      expect(docx.docx_listing_root).to eq docx_listing
    end

    it "when not descended from bulletin, returns nil" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)
      docx = create(:imports_docx, parent: uncat)

      expect(docx.docx_listing_root).to be_nil
    end
  end

  describe "#pdf_leaf" do
    context "when pdf exists" do
      it "returns the Imports::Pdf record" do
        docx = create(:imports_docx)
        pdf = create(:imports_pdf, parent: docx)

        expect(docx.pdf_leaf).to eq pdf
      end
    end

    context "when pdf does not exist" do
      it "returns nil" do
        docx = create(:imports_docx)

        expect(docx.pdf_leaf).to be_nil
      end
    end
  end

  describe "#pdf_leaves" do
    context "when pdf exists" do
      it "returns the Imports::Pdf record in an array" do
        docx = create(:imports_docx)
        pdf = create(:imports_pdf, parent: docx)

        expect(docx.pdf_leaves).to eq [pdf]
      end
    end

    context "when pdf does not exist" do
      it "returns empty array" do
        docx = create(:imports_docx)

        expect(docx.pdf_leaves).to be_empty
      end
    end
  end
end
