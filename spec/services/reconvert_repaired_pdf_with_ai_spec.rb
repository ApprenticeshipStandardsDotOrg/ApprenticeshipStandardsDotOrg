require "rails_helper"

RSpec.describe ReconvertRepairedPdfWithAI do
  let(:pdf) { create(:imports_pdf) }
  let(:prompt) { create(:open_ai_prompt, prompt: "Extract") }
  let(:standard) { create(:occupation_standard, :with_work_processes_and_competencies, source: :ai_conversion, rapids_code: "2028CB", status: :published) }
  let!(:attempt) { create(:open_ai_import, import: pdf, occupation_standard: standard) }
  let(:response) do
    {title: "Welder", rapidsCode: "2028CB", ojtType: "competency", registrationAgencyType: "oa", registrationState: "CA",
     workProcesses: [{title: "Welding", competencies: ["Inspect welds"]}],
     relatedInstructions: [{title: "Safety", hours: 20}]}
  end

  before do
    create(:registration_agency, for_state_abbreviation: "CA")
    pdf.update!(metadata: {"embedded_document_repair" => {"replacement_sha256" => Digest::SHA256.hexdigest(pdf.file.download)}})
    allow(PdfTextExtractor).to receive(:new).and_return(instance_double(PdfTextExtractor, call: "Complete PDF"))
    allow(ChatGptGenerateText).to receive(:new) { instance_double(ChatGptGenerateText, call: response.to_json) }
  end

  def convert
    described_class.new(import: pdf, open_ai_prompt: prompt).call
  end

  it "refreshes children in place while preserving the standard UUID and status" do
    original_id = standard.id
    old_process = standard.work_processes.first
    create(:related_instruction, occupation_standard: standard)

    expect { expect(convert.created).to be true }.not_to change(OccupationStandard, :count)

    expect(attempt.reload.occupation_standard_id).to eq original_id
    expect(standard.reload.title).to eq "Welder"
    expect(standard).to be_published
    expect(WorkProcess.exists?(old_process.id)).to be false
    expect(standard.work_processes.first.competencies.pluck(:title)).to eq ["Inspect welds"]
    expect(standard.related_instructions.pluck(:title)).to eq ["Safety"]
    expect(attempt.parsed_response["title"]).to eq "Welder"
    expect(convert.errors).to include "Already converted from this repaired PDF"
    expect(ChatGptGenerateText).to have_received(:new).once
  end

  it "stores a failed multi-occupation attempt without replacing the old standard data" do
    response[:documentOccupationCount] = 2
    original = standard.attributes
    process_ids = standard.work_processes.ids

    expect(convert.errors).to include "PDF appears to contain multiple occupations"

    expect(standard.reload.attributes).to eq original
    expect(standard.work_processes.ids).to eq process_ids
    expect(attempt.reload.extraction_errors).to include "PDF appears to contain multiple occupations"
    expect(pdf.reload.metadata["embedded_document_repair"]).not_to have_key("ai_conversion_sha256")
  end

  it "retries an earlier failed attempt" do
    attempt.update!(occupation_standard: nil, extraction_errors: ["Old failure"])

    expect { expect(convert.created).to be true }.to change(OccupationStandard, :count).by(1)

    expect(attempt.reload.occupation_standard).to be_source_ai_conversion
    expect(attempt.extraction_errors).to be_empty
  end

  it "rejects manual standards and changed RAPIDS identity" do
    standard.update!(source: :manual_upload)
    expect { convert }.to raise_error(/Refusing to overwrite/)
    standard.update!(source: :ai_conversion)
    response[:rapidsCode] = "9999"

    expect(convert.errors).to include "Extracted RAPIDS code differs from the existing AI standard"
    expect(standard.reload.rapids_code).to eq "2028CB"
  end

  it "rejects a PDF changed since repair before making an API call" do
    pdf.update!(metadata: {})

    expect { convert }.to raise_error(/does not match/)
    expect(ChatGptGenerateText).not_to have_received(:new)
  end

  it "records invalid JSON without losing the existing standard" do
    allow(ChatGptGenerateText).to receive(:new).and_return(instance_double(ChatGptGenerateText, call: "not JSON"))

    expect(convert.created).to be false
    expect(attempt.reload.occupation_standard_id).to eq standard.id
    expect(attempt.extraction_errors.join).to include "not valid JSON"
  end
end
