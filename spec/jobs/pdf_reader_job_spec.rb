require "rails_helper"

RSpec.describe PdfReaderJob do
  before do
  ActiveStorage::Current.url_options = {
    host: "localhost:3000"
  }
end
  describe "#perform" do
    it "returns if source file is not a pdf" do
      source_file = create(:source_file)
      allow_any_instance_of(SourceFile).to receive(:pdf?).and_return false
    
      expect(described_class.new.perform(source_file.id)).to be nil
    end


    it "returns an array of templates with ChatGPT responses" do
      source_file = create(:source_file)
      allow_any_instance_of(SourceFile).to receive(:pdf?).and_return true
      allow(
        ChatGptGenerateText
      ).to receive(:new).with(
        "Create an array of the occupation(s) from the text. Return as a JSON array [\"\"]"
      ).and_return chat_gpt_generator_mock("[\"Welder (Industrial)\"]")

      allow(
        ChatGptGenerateText
      ).to receive(:new).with(
        'Please fill out the template based on the given information for this occupation: Welder (Industrial) and return as JSON array information:[""] template: { "Title": "", "Type": "(Time based, Competency based, or Hybrid)" }'
      ).and_return chat_gpt_generator_mock("[\n  {\n    \"Title\": \"Welder (Industrial)\",\n    \"Type\": \"Competency based\"\n  }\n]")

      expect(described_class.new.perform(source_file.id)).to eq [{"Title"=>"Welder (Industrial)", "Type"=>"Competency based"}]
    end
  end
end

def chat_gpt_generator_mock(value)
  OpenStruct.new(call: value)
end