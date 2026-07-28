require "rails_helper"

RSpec.describe PdfReaderJob do
  describe "#perform" do
    it "returns an array of templates with ChatGPT responses" do
      user = create(:user)
      pdf = create(:imports_pdf, assignee: user)
      open_ai_prompt = create(:open_ai_prompt, name: "Sample prompt", prompt: "Prompt")

      reader_mock = instance_double "PDF::Reader"

      allow(PDF::Reader).to receive(:new).and_return(reader_mock)
      allow(reader_mock).to receive(:pages).and_return([instance_double("PDF::Reader::Page", text: "Welder (Industrial)\n(Competency based)\n\n")])

      create(:registration_agency, for_state_abbreviation: "CA")

      allow(ChatGptGenerateText).to receive(:new).with(
        "#{open_ai_prompt.prompt} [\"Welder (Industrial)\\n(Competency based)\\n\\n\"]"
      ).and_return chat_gpt_generator_mock(
        '{"title": "Welder (Industrial)","ojtType": "competency","registrationAgencyType": "oa","registrationState": "CA"}'
      )

      result = described_class.new.perform(
        import_id: pdf.id,
        open_ai_prompt: open_ai_prompt
      )

      open_ai_import = OpenAIImport.find_by(import: pdf)

      expect(result.created).to be true
      expect(open_ai_import).to be_present
      expect(open_ai_import.occupation_standard).to be_present
      expect(open_ai_import.occupation_standard).to be_source_ai_conversion
    end

    it "uses the default OpenAI prompt when one is not provided" do
      user = create(:user)
      pdf = create(:imports_pdf, assignee: user)
      open_ai_prompt = create(:open_ai_prompt, name: "Default prompt", prompt: "Default Prompt", default: true)

      reader_mock = instance_double "PDF::Reader"

      allow(PDF::Reader).to receive(:new).and_return(reader_mock)
      allow(reader_mock).to receive(:pages).and_return([instance_double("PDF::Reader::Page", text: "Welder")])
      create(:registration_agency, for_state_abbreviation: "CA")

      allow(ChatGptGenerateText).to receive(:new)
        .with("#{open_ai_prompt.prompt} [\"Welder\"]")
        .and_return chat_gpt_generator_mock(
          '{"title": "Welder","ojtType": "competency","registrationAgencyType": "oa","registrationState": "CA"}'
        )

      result = described_class.new.perform(import_id: pdf.id)

      expect(result.created).to be true
      expect(OpenAIImport.find_by(import: pdf)).to be_present
    end
  end
end

def chat_gpt_generator_mock(value)
  OpenStruct.new(call: value)
end
