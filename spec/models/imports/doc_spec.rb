require "rails_helper"

RSpec.describe Imports::Doc, type: :model do
  it_behaves_like "an imported file"

  describe "#process" do
    it "attaches a PDF to the Doc" do
      allow(ConvertDocToPdf).to receive(:call).and_return(
        Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf")
      )
      assignee = create(:user, :converter)
      doc = create(:imports_doc, public_document: true, courtesy_notification: :pending, assignee: assignee)

      doc.process
      doc.reload

      expect(doc.pdf).to be_present
      pdf = doc.pdf
      expect(pdf.status).to eq("pending")
      expect(pdf.public_document).to eq(true)
      expect(pdf.courtesy_notification).to eq("pending")
      expect(pdf.assignee).to eq assignee

      expect(doc.processed_at).to be_present
      expect(doc.processing_errors).to be_blank
      expect(doc.status).to eq("archived")
    end

    it "updates the Doc for missing soffice" do
      allow(ConvertDocToPdf).to receive(:call).and_raise(ConvertDocToPdf::PdfConversionError)
      doc = create(:imports_doc)

      expect_any_instance_of(ErrorSubscriber).to receive(:report).with(kind_of(ConvertDocToPdf::PdfConversionError), hash_including(context: {import_id: doc.id}, severity: :error)).and_call_original
      doc.process
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

  describe "#import_root" do
    it "retrieves the standards_import at the root" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)
      docx_listing = create(:imports_docx_listing, parent: uncat)
      doc = create(:imports_doc, parent: docx_listing)

      expect(doc.import_root).to eq standards_import
    end
  end

  describe "#docx_listing_root" do
    it "when descended from bulletin, retrieves the docx_listing ancestor" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)
      docx_listing = create(:imports_docx_listing, parent: uncat)
      uncat2 = create(:imports_uncategorized, parent: docx_listing)
      doc = create(:imports_doc, parent: uncat2)

      expect(doc.docx_listing_root).to eq docx_listing
    end

    it "when not descended from bulletin, returns nil" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)
      doc = create(:imports_doc, parent: uncat)

      expect(doc.docx_listing_root).to be_nil
    end
  end

  describe "#pdf_leaf" do
    context "when pdf exists" do
      it "returns the Imports::Pdf record" do
        doc = create(:imports_doc)
        pdf = create(:imports_pdf, parent: doc)

        expect(doc.pdf_leaf).to eq pdf
      end
    end

    context "when pdf does not exist" do
      it "returns nil" do
        doc = create(:imports_doc)

        expect(doc.pdf_leaf).to be_nil
      end
    end
  end

  describe "#pdf_leaves" do
    context "when pdf exists" do
      it "returns the Imports::Pdf record in an array" do
        doc = create(:imports_doc)
        pdf = create(:imports_pdf, parent: doc)

        expect(doc.pdf_leaves).to eq [pdf]
      end
    end

    context "when pdf does not exist" do
      it "returns empty array" do
        doc = create(:imports_doc)

        expect(doc.pdf_leaves).to be_empty
      end
    end
  end
end
