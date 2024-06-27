require "rails_helper"

RSpec.describe Imports::Uncategorized, type: :model do
  it_behaves_like "an imported file"

  describe ".needs_unfurling" do
    it "returns unfurled records that were created more than a day ago" do
      match_records = [
        create(:imports_uncategorized, status: :unfurled, created_at: 2.days.ago),
        create(:imports_docx, status: :unfurled, created_at: 26.hours.ago),
        create(:imports_doc, status: :unfurled, created_at: 1.week.ago)
      ]
      create(:imports_uncategorized, status: :unfurled, created_at: 23.hours.ago)
      create(:imports_docx, status: :unfurled)
      create(:imports_doc, status: :archived, created_at: 1.week.ago)

      expect(Import.needs_unfurling).to match_array match_records
    end
  end

  describe "#process" do
    it "detects Docx listings" do
      allow_any_instance_of(Imports::DocxListing).to receive(:process).with(hash_including(listing: false))
      import = create(:imports_uncategorized, :docx_listing)

      import.process(listing: true)
      import.reload

      expect(import.import).to be_a(Imports::DocxListing)
      expect(import.import).to be_unfurled
    end

    it "detects Docx files" do
      allow_any_instance_of(Imports::Docx).to receive(:process)
      import = create(:imports_uncategorized, :docx_listing)

      import.process(listing: false)
      import.reload

      expect(import.import).to be_a(Imports::Docx)
      expect(import.import).to be_unfurled
    end

    it "detects Doc files" do
      allow_any_instance_of(Imports::Doc).to receive(:process)
      import = create(:imports_uncategorized, :doc)

      import.process(listing: false)
      import.reload

      expect(import.import).to be_a(Imports::Doc)
      expect(import.import).to be_unfurled
    end

    it "detects PDF files" do
      allow_any_instance_of(Imports::Pdf).to receive(:process)
      import = create(:imports_uncategorized, :pdf)

      import.process(listing: false)
      import.reload

      expect(import.import).to be_a(Imports::Pdf)
      expect(import.import).to be_pending
    end

    it "processes the child" do
      pdf_import = double(:pdf, process: nil)
      import = create(:imports_uncategorized, :pdf)
      allow(import).to receive(:import).and_return(pdf_import)

      import.process(listing: false)

      expect(pdf_import).to have_received(:process).with(listing: false)
    end

    it "assigns .doc files of application/x-ole-storage as Doc files" do
      allow_any_instance_of(Imports::Doc).to receive(:process)
      import = create(:imports_uncategorized, file: Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "x-ole-storage.doc")))

      import.process(listing: false)
      import.reload

      expect(import.import).to be_a(Imports::Doc)
      expect(import.import).to be_unfurled
    end

    it "skips unknown files" do
      import = create(
        :imports_uncategorized,
        file: Rack::Test::UploadedFile.new(
          Rails.root.join("spec", "fixtures", "files", "oleObject1.bin"),
          "application/x-ole-storage"
        )
      )

      expect { import.process(listing: false) }.to raise_error(Imports::UnknownFileTypeError)
      import.reload

      expect(import.import).to be_blank
      expect(import.status).to eq("needs_backend_support")
      expect(import.processing_errors).to be_present
    end

    it "updates the processing data" do
      allow_any_instance_of(Imports::Pdf).to receive(:process)
      import = create(:imports_uncategorized, :pdf)

      import.process(listing: false)
      import.reload

      expect(import.processed_at).to be_present
      expect(import.processing_errors).to be_blank
      expect(import.status).to eq("archived")
    end

    it "stores errors" do
      import = create(:imports_uncategorized, :pdf)
      allow(import).to receive(:import).and_raise(ActiveRecord::RecordNotUnique)

      expect { import.process(listing: false) }.to raise_error(ActiveRecord::RecordNotUnique)
      import.reload

      expect(import.processed_at).to be_blank
      expect(import.processing_errors).to be_present
      expect(import.status).to eq("needs_backend_support")
    end
  end

  describe "#pdf_leaf" do
    context "when pdf leaf exists" do
      it "returns the Imports::Pdf record" do
        uncat = create(:imports_uncategorized)
        doc = create(:imports_doc, parent: uncat)
        pdf = create(:imports_pdf, parent: doc)

        expect(uncat.pdf_leaf).to eq pdf
      end
    end

    context "when import is a docx_listing" do
      it "returns nil" do
        uncat = create(:imports_uncategorized)
        create(:imports_docx_listing, parent: uncat)

        expect(uncat.pdf_leaf).to be_nil
      end
    end

    context "when pdf leaf does not exist" do
      it "returns nil" do
        uncat = create(:imports_uncategorized)

        expect(uncat.pdf_leaf).to be_nil
      end
    end
  end

  describe "#pdf_leaves" do
    context "when pdf leaf exists" do
      it "returns the Imports::Pdf record in an array" do
        uncat = create(:imports_uncategorized)
        doc = create(:imports_doc, parent: uncat)
        pdf = create(:imports_pdf, parent: doc)

        expect(uncat.pdf_leaves).to eq [pdf]
      end
    end

    context "when import is a docx_listing" do
      it "returns docx_listing pdf_leaves" do
        uncat = create(:imports_uncategorized)
        docx_listing = create(:imports_docx_listing, parent: uncat)
        uncat1 = create(:imports_uncategorized, parent: docx_listing)
        uncat2 = create(:imports_uncategorized, parent: docx_listing)
        uncat3 = create(:imports_uncategorized, parent: docx_listing)

        doc = create(:imports_doc, parent: uncat1)
        pdf1 = create(:imports_pdf, parent: doc)

        docx = create(:imports_docx, parent: uncat2)
        pdf2 = create(:imports_pdf, parent: docx)

        pdf3 = create(:imports_pdf, parent: uncat3)

        expect(uncat.pdf_leaves).to contain_exactly(pdf1, pdf2, pdf3)
      end
    end

    context "when pdf leaf does not exist" do
      it "returns empty array" do
        uncat = create(:imports_uncategorized)

        expect(uncat.pdf_leaves).to be_empty
      end
    end
  end

  describe "#import_root" do
    it "retrieves the standards_import at the root" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)

      expect(uncat.import_root).to eq standards_import
    end
  end

  describe "#docx_listing_root" do
    it "when descended from bulletin, retrieves the docx_listing ancestor" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)
      docx_listing = create(:imports_docx_listing, parent: uncat)
      uncat2 = create(:imports_uncategorized, parent: docx_listing)

      expect(uncat2.docx_listing_root).to eq docx_listing
    end

    it "when not descended from bulletin, returns nil" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)

      expect(uncat.docx_listing_root).to be_nil
    end
  end

  describe "#filename" do
    it "returns filename if file attached" do
      import = create(:imports_uncategorized)

      expect(import.filename).to eq "pixel1x1.pdf"
    end

    it "returns empty string if no file attached" do
      import = create(:imports_uncategorized, file: nil)

      expect(import.filename).to be_blank
    end
  end
end
