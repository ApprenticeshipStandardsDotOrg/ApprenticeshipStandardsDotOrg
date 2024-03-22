require "rails_helper"

RSpec.describe PdfReaderJob do
  describe "#perform" do
    let(:pdf_file) { "" }

    before do
      allow_any_instance_of(SourceFile).to receive(:url).and_return("http://example.com/mock.pdf")
      stub_request(:get, "http://example.com/mock.pdf").to_return(status: 200, body: pdf_file)
    end

    it "returns if source file is not a pdf" do
      source_file = create(:source_file)
      allow_any_instance_of(SourceFile).to receive(:pdf?).and_return false

      expect(described_class.new.perform(source_file.id)).to be nil
    end

    it "returns an array of templates with ChatGPT responses" do
      source_file = create(:source_file)
      allow_any_instance_of(SourceFile).to receive(:pdf?).and_return true

      stub_request(:get, source_file.url).to_return(status: 200, body: "", headers: {})
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

      expect(described_class.new.perform(source_file.id)).to eq [{"Title" => "Welder (Industrial)", "Type" => "Competency based"}]
    end
  end
end

def chat_gpt_generator_mock(value)
  OpenStruct.new(call: value)
end
