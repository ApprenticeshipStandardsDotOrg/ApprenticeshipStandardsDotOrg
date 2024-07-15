require "rails_helper"

RSpec.describe PdfArchiveEvaluatorJob do
  describe "#perform" do
    let(:pdf1) { create(:imports_pdf, status: :pending, file: Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "oleObject4.pdf"), "application/pdf")) }
    let(:pdf2) { create(:imports_pdf, status: :pending) }
    let(:pdf3) { create(:imports_pdf, status: :pending) }
    let(:pdf_reader) { instance_double "PDF::Reader" }
    let(:job) { described_class.new }

    it "archives pdf files that match the archive criteria" do
      allow(PDF::Reader).to receive(:new).and_return(pdf_reader)
      allow(job).to receive(:archive_criteria).and_return(["apprentice agreement and registration"])
      allow(job).to receive(:extract_pdf_content).and_return("apprenticeships apprentice agreement and registration")

      allow(job).to receive(:contains_appendix_a?).and_return false
      allow(job).to receive(:match_criteria?).and_return true

      expect { job.perform }.to change { pdf1.reload.status }.from("pending").to("archived")
    end

    it "does not archive a pdf file that does not match the filename criteria" do
      expect { described_class.perform_now }.not_to change(pdf2, :status)
    end

    it "does not archive a pdf file that contains an Appendix A" do
      allow(pdf3).to receive(:filename).and_return("oleObject.pdf")
      allow(PDF::Reader).to receive(:new).and_return(pdf_reader)
      allow(job).to receive(:extract_pdf_content).and_return("apprenticeship appendix a")

      allow(ChatGptGenerateText).to receive(:new).with(
        "Does the following content contain a dedicated Appendix A page? References to an Appendix A do not count. Capitalization does not matter. Return 'true' or 'false'. Content: apprenticeship appendix a"
      ).and_return chat_gpt_generator_mock("true")

      expect { job.perform_now }.not_to change(pdf3, :status)
    end
  end
end

def chat_gpt_generator_mock(value)
  OpenStruct.new(call: value)
end
