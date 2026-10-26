require "rails_helper"

RSpec.describe "Multi-occupation PDF conversion" do
  let(:pdf) { create(:imports_pdf) }
  let(:prompt) { create(:open_ai_prompt, prompt: "Extract every occupation") }
  let(:oa) { create(:registration_agency, for_state_abbreviation: "CA", agency_type: :oa) }
  let(:saa) { create(:registration_agency, for_state_abbreviation: "SC", agency_type: :saa) }
  let(:payload) do
    {
      documentOccupationCount: 2,
      singleOccupation: false,
      occupations: [
        {title: "Welder", rapidsCode: "2028CB", ojtType: "competency", registrationState: "CA", registrationAgencyType: "oa",
         workProcesses: [{title: "Welding", competencies: [{title: "Inspect welds"}]}], relatedInstructions: [{title: "Welding safety", hours: 20}]},
        {title: "Electrician", rapidsCode: "0159HY", ojtType: "hybrid", registrationState: "SC", registrationAgencyType: "saa",
         workProcesses: [{title: "Wiring", maximumHours: 100, competencies: [{title: "Test circuits"}]}], relatedInstructions: [{title: "Electrical safety", hours: 30}]}
      ]
    }
  end

  before do
    oa
    saa
    allow(PdfTextExtractor).to receive(:new).and_return(instance_double(PdfTextExtractor, call: "Two occupation appendices"))
    allow(ChatGptGenerateText).to receive(:new) { instance_double(ChatGptGenerateText, call: payload.to_json) }
  end

  def convert(force: false)
    ConvertPdfImportWithAI.new(import: pdf, open_ai_prompt: prompt, force: force).call
  end

  it "creates separate OA/SAA standards with isolated processes, competencies, RTI, and provenance" do
    result = convert

    expect(result.created).to be true
    expect(result.errors).to be_empty
    expect(result.occupation_standards.size).to eq 2
    welder, electrician = result.occupation_standards.sort_by(&:title).reverse
    expect(welder.title).to eq "Welder"
    expect(welder.registration_agency).to eq oa
    expect(welder.work_processes.pluck(:title)).to eq ["Welding"]
    expect(welder.work_processes.first.competencies.pluck(:title)).to eq ["Inspect welds"]
    expect(welder.related_instructions.pluck(:title)).to eq ["Welding safety"]
    expect(electrician.registration_agency).to eq saa
    expect(electrician.work_processes.pluck(:title)).to eq ["Wiring"]
    expect(electrician.related_instructions.pluck(:title)).to eq ["Electrical safety"]
    expect(electrician.source_imports).to eq [pdf]
    expect(pdf.reload.associated_occupation_standards.map(&:id)).to match_array([welder.id, electrician.id])
    expect(pdf).to be_archived
    expect(welder.open_ai_import.parsed_response["workProcesses"].first["title"]).to eq "Welding"
  end

  it "matches each RAPIDS baseline to its occupation instead of the first PDF result" do
    welder = create(:occupation_standard, source: :rapids_api, title: "Welder", rapids_code: "2028")
    electrician = create(:occupation_standard, source: :rapids_api, title: "Electrician", rapids_code: "0159")
    create(:data_import, import: pdf, occupation_standard: welder)
    create(:data_import, import: pdf, occupation_standard: electrician)
    convert

    expect(pdf.ai_import_for(welder).occupation_standard.title).to eq "Welder"
    expect(pdf.ai_import_for(electrician).occupation_standard.title).to eq "Electrician"
    expect(welder.reload.title).to eq "Welder"
    expect(electrician.reload.rapids_code).to eq "0159"
  end

  it "retains all AI standard UUIDs on a forced refresh without duplicating records" do
    convert
    ids = pdf.open_ai_imports.reload.map(&:occupation_standard_id).sort
    payload[:occupations].first[:workProcesses].first[:title] = "Updated welding"

    expect { expect(convert(force: true).created).to be true }.not_to change(OccupationStandard, :count)

    expect(pdf.open_ai_imports.reload.map(&:occupation_standard_id).sort).to eq ids
    expect(OccupationStandard.find(ids).find { |s| s.title == "Welder" }.work_processes.pluck(:title)).to eq ["Updated welding"]
  end

  it "skips an already-converted document without another API call" do
    convert
    expect(convert.created).to be false
    expect(ChatGptGenerateText).to have_received(:new).once
  end

  it "keeps valid occupations when another entry fails and exposes its errors" do
    payload[:occupations].last.delete(:ojtType)

    result = convert

    expect(result.created).to be false
    expect(result.occupation_standards.map(&:title)).to eq ["Welder"]
    expect(result.errors.join).to include "Electrician: Could not extract OJT type"
    expect(pdf.reload).to be_needs_human_review
    expect(pdf.ai_conversion_errors).to include "Electrician: Could not extract OJT type"
  end

  it "reports a truncated occupation set rather than calling the document complete" do
    payload[:documentOccupationCount] = 4

    result = convert

    expect(result.errors.join).to include "expected 4, received 2"
    expect(result.created).to be false
    expect(result.occupation_standards.size).to eq 2
  end

  it "does not create duplicate standards for repeated identical occupation entries" do
    payload[:occupations][1] = payload[:occupations][0].deep_dup

    result = convert

    expect(result.occupation_standards.size).to eq 1
    expect(result.errors.join).to include "Duplicate occupation section"
  end

  it "retains but flags an old AI standard absent from the new extraction" do
    old = create(:occupation_standard, source: :ai_conversion, title: "Carpenter", rapids_code: "0067")
    previous = create(:open_ai_import, import: pdf, occupation_standard: old)

    result = convert(force: true)

    expect(result.created).to be false
    expect(result.errors.join).to include "Previously converted occupation was not found"
    expect(result.occupation_standards.map(&:title)).to match_array(["Welder", "Electrician"])
    expect(previous.reload.occupation_standard_id).to eq old.id
    expect(old.reload.title).to eq "Carpenter"
    expect(pdf.ai_import_for(old)).to be_nil
  end

  it "preserves separate UUIDs for same-code same-title standards with distinct appendices" do
    payload[:occupations][1] = payload[:occupations][0].deep_dup
    payload[:occupations][0][:appendixLabel] = "A1"
    payload[:occupations][1][:appendixLabel] = "A2"
    expect(convert.created).to be true
    ids = pdf.open_ai_imports.reload.to_h { |attempt| [attempt.parsed_response["appendixLabel"], attempt.occupation_standard_id] }

    expect { expect(convert(force: true).created).to be true }.not_to change(OccupationStandard, :count)

    expect(pdf.open_ai_imports.reload.to_h { |attempt| [attempt.parsed_response["appendixLabel"], attempt.occupation_standard_id] }).to eq ids
  end
end
