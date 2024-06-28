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
        "Create an array of the occupation(s) from the text. Return as a JSON array [\"Welder (Industrial)\\n(Competency based)\\n\\n\"]"
      ).and_return chat_gpt_generator_mock("[\"Welder (Industrial)\"]")

      allow(
        ChatGptGenerateText
      ).to receive(:new).with(
        "Please fill out the template based on the given information for this occupation: Welder (Industrial) and return as JSON array information:[\"Welder (Industrial)\\n(Competency based)\\n\\n\"] template: { \"Title\": \"\", \"Type\": \"(Time based, Competency based, or Hybrid)\" }"
      ).and_return chat_gpt_generator_mock("[\n  {\n    \"Title\": \"Welder (Industrial)\",\n    \"Type\": \"Competency based\"\n  }\n]")

      expect(described_class.new.perform(pdf.id)).to eq [{"Title" => "Welder (Industrial)", "Type" => "Competency based"}]
    end
  end
end

def chat_gpt_generator_mock(value)
  OpenStruct.new(call: value)
end
