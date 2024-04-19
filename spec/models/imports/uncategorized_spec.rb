require "rails_helper"

RSpec.describe Imports::Uncategorized, type: :model do
  it_behaves_like "an imported file"

  describe "#process" do
    it "detects Docx listings" do
      allow_any_instance_of(Imports::DocxListing).to receive(:process)
      import = create(:imports_uncategorized, :docx_listing)

      import.process(listing: true)
      import.reload

      expect(import.import).to be_a(Imports::DocxListing)
    end

    it "detects Docx files" do
      allow_any_instance_of(Imports::Docx).to receive(:process)
      import = create(:imports_uncategorized, :docx_listing)

      import.process(listing: false)
      import.reload

      expect(import.import).to be_a(Imports::Docx)
    end

    it "detects Doc files" do
      allow_any_instance_of(Imports::Doc).to receive(:process)
      import = create(:imports_uncategorized, :doc)

      import.process(listing: false)
      import.reload

      expect(import.import).to be_a(Imports::Doc)
    end

    it "detects PDF files" do
      allow_any_instance_of(Imports::Pdf).to receive(:process)
      import = create(:imports_uncategorized, :pdf)

      import.process(listing: false)
      import.reload

      expect(import.import).to be_a(Imports::Pdf)
    end

    it "processes the child" do
      pdf_import = double(:pdf, process: nil)
      import = create(:imports_uncategorized, :pdf)
      allow(import).to receive(:import).and_return(pdf_import)

      import.process(listing: false)

      expect(pdf_import).to have_received(:process).with(listing: false)
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
      pdf_import = double(:pdf, process: nil)
      import = create(:imports_uncategorized, :pdf)
      allow(import).to receive(:import).and_raise(ActiveRecord::RecordNotUnique)

      expect { import.process(listing: false) }.to raise_error(ActiveRecord::RecordNotUnique)
      import.reload

      expect(import.processed_at).to be_blank
      expect(import.processing_errors).to be_present
      expect(import.status).to eq("needs_backend_support")
    end
  end
end
