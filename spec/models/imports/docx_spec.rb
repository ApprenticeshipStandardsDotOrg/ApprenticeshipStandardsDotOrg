require "rails_helper"

RSpec.describe Imports::Docx, type: :model do
  it_behaves_like "an imported file"

  describe "#process" do
    it "attaches a PDF to the Docx" do
      docx = create(:imports_docx, public_document: true)

      docx.process
      docx.reload

      expect(docx.pdf).to be_present
      pdf = docx.pdf
      expect(pdf.status).to eq("completed")
      expect(pdf.public_document).to eq(true)
      expect(pdf.courtesy_notification).to eq("not_required")

      expect(docx.processed_at).to be_present
      expect(docx.processing_errors).to be_blank
      expect(docx.status).to eq("completed")
    end

    it "updates the Docx for missing soffice" do
      docx = create(:imports_docx)
      stub_soffice_install(installed: false)

      docx.process
      docx.reload

      expect(docx.pdf).to be_blank
      expect(docx.processed_at).to be_blank
      expect(docx.processing_errors).to be_present
      expect(docx.status).to eq("needs_support")
    end

    it "updates the Docx for failed soffice" do
      docx = create(:imports_docx)
      stub_soffice_install(installed: true)
      stub_soffice_conversion(successful: false)

      docx.process
      docx.reload

      expect(docx.pdf).to be_blank
      expect(docx.processed_at).to be_blank
      expect(docx.processing_errors).to be_present
      expect(docx.status).to eq("needs_support")
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

