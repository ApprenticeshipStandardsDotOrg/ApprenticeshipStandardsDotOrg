require "rails_helper"

RSpec.describe PdfReaderJob do
  it "enqueues PDF conversions on the dedicated AI queue" do
    expect { described_class.perform_later(import_id: "pdf-id", force: true) }
      .to have_enqueued_job(described_class).with(import_id: "pdf-id", force: true).on_queue("ai_conversion")
  end

  describe "#perform" do
    it "logs stored validation failures while completing the job" do
      pdf = create(:imports_pdf)
      prompt = create(:open_ai_prompt)
      result = ConvertPdfImportWithAI::Result.new(open_ai_import: nil, occupation_standard: nil, created: false, errors: ["Nurse: missing OJT type"])
      allow(ConvertPdfImportWithAI).to receive(:new).and_return(instance_double(ConvertPdfImportWithAI, call: result))
      expect(Rails.logger).to receive(:warn).with("AI conversion for import #{pdf.id}: Nurse: missing OJT type")

      expect(described_class.new.perform(import_id: pdf.id, open_ai_prompt: prompt)).to eq result
    end

    it "returns an array of templates with ChatGPT responses" do
      user = create(:user)
      pdf = create(:imports_pdf, assignee: user)
      open_ai_prompt = create(:open_ai_prompt, name: "Sample prompt", prompt: "Prompt")

      reader_mock = instance_double "PDF::Reader"

      allow(PDF::Reader).to receive(:new).and_return(reader_mock)
      allow(reader_mock).to receive(:pages).and_return([instance_double("PDF::Reader::Page", text: "Welder (Industrial)\n(Competency based)\n\n")])

      create(:registration_agency, for_state_abbreviation: "CA")

      allow(ChatGptGenerateText).to receive(:new).with(
        "#{open_ai_prompt.prompt} --- Page 1 ---\nWelder (Industrial)\n(Competency based)\n\n"
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
        .with("#{open_ai_prompt.prompt} --- Page 1 ---\nWelder")
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
