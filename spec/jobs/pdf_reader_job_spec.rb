require "rails_helper"

RSpec.describe PdfReaderJob do
  describe "#perform" do
    it "returns an array of templates with ChatGPT responses" do
      pdf = create(:imports_pdf)

      reader_mock = instance_double "PDF::Reader"

      allow(PDF::Reader).to receive(:new).and_return(reader_mock)
      allow(reader_mock).to receive(:pages).and_return([instance_double("PDF::Reader::Page", text: "Welder (Industrial)\n(Competency based)\n\n")])

      allow(
        ChatGptGenerateText
      ).to receive(:new).with(
        "#{PdfReaderJob::BASE_PROMPT} [\"Welder (Industrial)\\n(Competency based)\\n\\n\"]"
      ).and_return chat_gpt_generator_mock('{"Title": "Welder (Industrial)","Type": "competency" }')

      parsed_response = JSON.parse(described_class.new.perform(pdf.id))

      expect(parsed_response).to eq({"Title" => "Welder (Industrial)", "Type" => "competency"})
    end
  end
end

def chat_gpt_generator_mock(value)
  OpenStruct.new(call: value)
end
