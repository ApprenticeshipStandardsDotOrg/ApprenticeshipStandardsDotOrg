require "rails_helper"

RSpec.describe Imports::Uncategorized, type: :model do
  it_behaves_like "an imported file"

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

  describe "#import_root" do
    it "retrieves the standards_import at the root" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)

      expect(uncat.import_root).to eq standards_import
    end
  end
end
