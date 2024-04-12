require "rails_helper"

RSpec.describe Imports::Doc, type: :model do
  it_behaves_like "an imported file"

  describe "#process" do
    it "attaches a PDF to the Doc" do
      doc = create(:imports_doc, public_document: true)

      doc.process
      doc.reload

      expect(doc.pdf).to be_present
      pdf = doc.pdf
      expect(pdf.status).to eq("pending")
      expect(pdf.public_document).to eq(true)
      expect(pdf.courtesy_notification).to eq("not_required")

      expect(doc.processed_at).to be_present
      expect(doc.processing_errors).to be_blank
      expect(doc.status).to eq("completed")
    end

    it "updates the Doc for missing soffice" do
      doc = create(:imports_doc)
      stub_soffice_install(installed: false)

      doc.process
      doc.reload

      expect(doc.pdf).to be_blank
      expect(doc.processed_at).to be_blank
      expect(doc.processing_errors).to be_present
      expect(doc.status).to eq("needs_support")
    end

    it "updates the Doc for failed soffice" do
      doc = create(:imports_doc)
      stub_soffice_install(installed: true)
      stub_soffice_conversion(successful: false)

      doc.process
      doc.reload

      expect(doc.pdf).to be_blank
      expect(doc.processed_at).to be_blank
      expect(doc.processing_errors).to be_present
      expect(doc.status).to eq("needs_support")
    end
  end

  def stub_soffice_install(installed:)
    allow(Kernel).to receive(:system)
      .with("soffice --version")
      .and_return(installed)
  end

  def stub_soffice_conversion(successful:)
    allow(Kernel).to receive(:system)
      .with(/soffice --headless --convert-to pdf .*/)
      .and_return(successful)
  end
end
