require "rails_helper"

RSpec.describe PdfArchiveEvaluator do
  describe "#call" do
    it "archives pdf files that match the archive criteria" do
      pdf = create(:imports_pdf)
      service = described_class.new(pdf)
      pdf_reader = instance_double "PDF::Reader"

      allow(pdf).to receive(:filename).and_return("oleObject4.pdf")
      allow(PDF::Reader).to receive(:new).and_return(pdf_reader)
      allow(service).to receive(:archive_criteria).and_return(['apprentice agreement and registration'])
      allow(service).to receive(:extract_pdf_content).and_return("apprenticeships apprentice agreement and registration")

      allow(ChatGptGenerateText).to receive(:new).with(
        "Does the following content contain an Appendix A? Capitalization does not matter. Return 'true' or 'false'. Content: apprenticeships apprentice agreement and registration"
      ).and_return chat_gpt_generator_mock('false')

      allow(ChatGptGenerateText).to receive(:new).with(
        "Does the following content contain any of these titles, [\"apprentice agreement and registration\"]? Capitalization does not matter. Return 'true' or 'false'. Content: apprenticeships apprentice agreement and registration"
      ).and_return chat_gpt_generator_mock('true')

      expect { service.call }.to change(pdf, :status).from("pending").to("archived")
    end

    it "does not archive a pdf file that does not match the filename criteria" do
      pdf = create(:imports_pdf)
      service = described_class.new(pdf)

      allow(ChatGptGenerateText).to receive(:new).and_return chat_gpt_generator_mock('false')

      expect { service.call }.not_to change(pdf, :status)
    end

    it "does not archive a pdf file that contains an Appendix A" do
      pdf = create(:imports_pdf)
      service = described_class.new(pdf)
      pdf_reader = instance_double "PDF::Reader"

      allow(pdf).to receive(:filename).and_return("oleObject.pdf")
      allow(PDF::Reader).to receive(:new).and_return(pdf_reader)
      allow(service).to receive(:archive_criteria).and_return(['apprentice agreement and registration'])
      allow(service).to receive(:extract_pdf_content).and_return("apprenticeship appendix a")

      allow(ChatGptGenerateText).to receive(:new).with(
        "Does the following content contain an Appendix A? Capitalization does not matter. Return 'true' or 'false'. Content: apprenticeship appendix a"
      ).and_return chat_gpt_generator_mock('true')

      expect { service.call }.not_to change(pdf, :status)
    end
  end
end

def chat_gpt_generator_mock(value)
  OpenStruct.new(call: value)
end
