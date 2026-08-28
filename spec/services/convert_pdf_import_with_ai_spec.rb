require "rails_helper"

RSpec.describe ConvertPdfImportWithAI do
  describe "#call" do
    it "creates an occupation standard from the OpenAI response" do
      pdf = create(:imports_pdf)
      prompt = create(:open_ai_prompt, prompt: "Extract")
      registration_agency = create(:registration_agency, for_state_abbreviation: "CA")
      organization = create(:organization, title: "Acme")
      occupation = create(:occupation, rapids_code: "2028CB")
      create(:industry, prefix: "51", version: Industry::CURRENT_VERSION)

      stub_pdf_text("Welder standard")
      stub_open_ai_response(prompt, "Welder standard", {
        title: "Welder",
        existingTitle: "Welder Existing",
        onetCode: "51-4121.00",
        rapidsCode: "2028CB",
        organization: organization.title,
        ojtType: "competency",
        registrationAgencyType: "oa",
        registrationState: "CA",
        workProcesses: [
          {
            title: "Welding",
            minimumHours: 100,
            competencies: [{title: "Inspect welds"}]
          }
        ],
        relatedInstructions: [
          {
            title: "Safety",
            hours: 20
          }
        ]
      }.to_json)
      expect_any_instance_of(OccupationStandard).not_to receive(:update_document)

      result = described_class.new(import: pdf, open_ai_prompt: prompt).call

      occupation_standard = result.occupation_standard

      expect(result.created).to be true
      expect(occupation_standard).to be_persisted
      expect(occupation_standard).to be_source_ai_conversion
      expect(occupation_standard.title).to eq "Welder"
      expect(occupation_standard.rapids_code).to eq "2028CB"
      expect(occupation_standard.registration_agency).to eq registration_agency
      expect(occupation_standard.organization).to eq organization
      expect(occupation_standard.occupation).to eq occupation
      expect(occupation_standard.work_processes.first.competencies.first.title).to eq "Inspect welds"
      expect(occupation_standard.related_instructions.first.title).to eq "Safety"
      expect(pdf.reload).to be_archived
      expect(result.open_ai_import.parsed_response["title"]).to eq "Welder"
      expect(result.open_ai_import.extraction_errors).to eq []
    end

    it "uses the national registration agency when no state is available" do
      pdf = create(:imports_pdf)
      prompt = create(:open_ai_prompt, prompt: "Extract")
      national_agency = create(:registration_agency, :for_national_program, agency_type: :oa)

      stub_pdf_text("Federal standard")
      stub_open_ai_response(prompt, "Federal standard", {
        title: "Welder",
        ojtType: "competency",
        registrationAgencyType: "oa",
        state: nil,
        registrationState: nil
      }.to_json)
      expect_any_instance_of(OccupationStandard).not_to receive(:update_document)

      result = described_class.new(import: pdf, open_ai_prompt: prompt).call

      expect(result.created).to be true
      expect(result.occupation_standard.registration_agency).to eq national_agency
      expect(result.occupation_standard.state).to be_nil
    end

    it "prefers a state registration agency when OpenAI also returns a national standard type" do
      pdf = create(:imports_pdf)
      prompt = create(:open_ai_prompt, prompt: "Extract")
      alabama_agency = create(:registration_agency, for_state_abbreviation: "AL", agency_type: :saa)

      stub_pdf_text("Alabama program standard")
      stub_open_ai_response(prompt, "Alabama program standard", {
        title: "Automobile Body Repairer",
        ojtType: "competency",
        registrationAgencyType: "saa",
        registrationState: "AL",
        nationalStandardType: "program_standard"
      }.to_json)
      expect_any_instance_of(OccupationStandard).not_to receive(:update_document)

      result = described_class.new(import: pdf, open_ai_prompt: prompt).call

      expect(result.created).to be true
      expect(result.occupation_standard.registration_agency).to eq alabama_agency
      expect(result.occupation_standard.national_standard_type).to be_nil
    end

    it "uses the state's authoritative registration agency when OpenAI returns the wrong agency type" do
      pdf = create(:imports_pdf)
      prompt = create(:open_ai_prompt, prompt: "Extract")
      colorado_agency = create(:registration_agency, for_state_abbreviation: "CO", agency_type: :saa)

      stub_pdf_text("Colorado teacher standard")
      stub_open_ai_response(prompt, "Colorado teacher standard", {
        title: "Special Education Teacher",
        ojtType: "competency",
        registrationAgencyType: "oa",
        registrationState: "CO"
      }.to_json)
      expect_any_instance_of(OccupationStandard).not_to receive(:update_document)

      result = described_class.new(import: pdf, open_ai_prompt: prompt).call

      expect(result.created).to be true
      expect(result.occupation_standard.registration_agency).to eq colorado_agency
    end

    it "extracts work process, skill, and related instruction data from alternate response keys" do
      pdf = create(:imports_pdf)
      prompt = create(:open_ai_prompt, prompt: "Extract")
      create(:registration_agency, for_state_abbreviation: "CA")

      stub_pdf_text("Machinist standard")
      stub_open_ai_response(prompt, "Machinist standard", {
        title: "Machinist",
        ojtType: "time",
        registrationAgencyType: "oa",
        registrationState: "CA",
        onTheJobTraining: [
          {
            name: "Operate CNC machines",
            hours: "1,200",
            skills: [
              {skill: "Set up CNC tooling"},
              {task: "Inspect finished parts"}
            ]
          }
        ],
        relatedTechnicalInstruction: [
          {
            courseTitle: "Blueprint Reading",
            estimatedHours: "144"
          }
        ]
      }.to_json)
      expect_any_instance_of(OccupationStandard).not_to receive(:update_document)

      result = described_class.new(import: pdf, open_ai_prompt: prompt).call
      occupation_standard = result.occupation_standard

      expect(result.created).to be true
      expect(occupation_standard.work_processes.first.title).to eq "Operate CNC machines"
      expect(occupation_standard.work_processes.first.maximum_hours).to eq 1200
      expect(occupation_standard.work_processes.first.competencies.map(&:title)).to eq [
        "Set up CNC tooling",
        "Inspect finished parts"
      ]
      expect(occupation_standard.related_instructions.first.title).to eq "Blueprint Reading"
      expect(occupation_standard.related_instructions.first.hours).to eq 144
    end

    it "allows either California agency because California has both OA and SAA agencies" do
      pdf = create(:imports_pdf)
      prompt = create(:open_ai_prompt, prompt: "Extract")
      california = create(:state, abbreviation: "CA")
      create(:registration_agency, state: california, agency_type: :oa)
      california_saa = create(:registration_agency, state: california, agency_type: :saa)

      stub_pdf_text("California teacher standard")
      stub_open_ai_response(prompt, "California teacher standard", {
        title: "Special Education Teacher",
        ojtType: "competency",
        registrationAgencyType: "saa",
        registrationState: "CA"
      }.to_json)
      expect_any_instance_of(OccupationStandard).not_to receive(:update_document)

      result = described_class.new(import: pdf, open_ai_prompt: prompt).call

      expect(result.created).to be true
      expect(result.occupation_standard.registration_agency).to eq california_saa
    end

    it "stores extraction errors without creating an invalid occupation standard" do
      pdf = create(:imports_pdf)
      prompt = create(:open_ai_prompt, prompt: "Extract")
      create(:registration_agency, :for_national_program, agency_type: :oa)

      stub_pdf_text("Incomplete standard")
      stub_open_ai_response(prompt, "Incomplete standard", {
        title: "Welder"
      }.to_json)

      result = described_class.new(import: pdf, open_ai_prompt: prompt).call

      expect(result.created).to be false
      expect(result.open_ai_import).to be_persisted
      expect(result.open_ai_import.occupation_standard).to be_nil
      expect(result.errors.join).to include "Could not extract OJT type"
      expect(pdf.reload).to be_pending
    end

    it "replaces a failed AI import when forced" do
      pdf = create(:imports_pdf)
      prompt = create(:open_ai_prompt, prompt: "Extract")
      failed_open_ai_import = create(
        :open_ai_import,
        import: pdf,
        occupation_standard: nil,
        extraction_errors: ["Could not resolve registration agency"]
      )
      create(:registration_agency, for_state_abbreviation: "CA")

      stub_pdf_text("Retryable standard")
      stub_open_ai_response(prompt, "Retryable standard", {
        title: "Welder",
        ojtType: "competency",
        registrationAgencyType: "oa",
        registrationState: "CA"
      }.to_json)
      expect_any_instance_of(OccupationStandard).not_to receive(:update_document)

      result = described_class.new(import: pdf, open_ai_prompt: prompt, force: true).call

      expect(result.created).to be true
      expect(result.open_ai_import).to be_persisted
      expect(result.open_ai_import).to_not eq failed_open_ai_import
      expect(OpenAIImport.exists?(failed_open_ai_import.id)).to be false
      expect(result.occupation_standard).to be_persisted
    end
  end

  def stub_pdf_text(text)
    reader = instance_double("PDF::Reader")

    allow(PDF::Reader).to receive(:new).and_return(reader)
    allow(reader).to receive(:pages).and_return([
      instance_double("PDF::Reader::Page", text: text)
    ])
  end

  def stub_open_ai_response(prompt, pdf_text, response)
    allow(ChatGptGenerateText).to receive(:new)
      .with("#{prompt.prompt} #{formatted_pdf_text(pdf_text)}")
      .and_return(OpenStruct.new(call: response))
  end

  def formatted_pdf_text(text)
    "--- Page 1 ---\n#{text}"
  end
end
