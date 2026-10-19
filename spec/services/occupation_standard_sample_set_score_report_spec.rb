require "rails_helper"
require "csv"

RSpec.describe OccupationStandardSampleSetScoreReport do
  def report_row(standard)
    CSV.parse(described_class.new(OccupationStandard.where(id: standard.id), filters: "").to_csv, headers: true).first
  end

  let(:baseline) do
    create(:occupation_standard, :with_data_import, source: :rapids_api,
      title: "Industrial Maintenance Mechanic", onet_code: "49-9041.00", rapids_code: "0308")
  end
  let(:actual) do
    create(:occupation_standard, source: :ai_conversion, title: "Industrial Maintenance Mechanic!",
      occupation: baseline.occupation, onet_code: baseline.onet_code, rapids_code: baseline.rapids_code,
      registration_agency: baseline.registration_agency, ojt_type: baseline.ojt_type)
  end

  def convert(response = {})
    create(:open_ai_import, import: baseline.data_imports.first.import, occupation_standard: actual, parsed_response: response)
  end

  it "awards all 11 points for matching fields and equivalent content with different grouping" do
    create(:work_process, occupation_standard: baseline, title: "Maintain pumps", description: nil)
    create(:work_process, occupation_standard: baseline, title: "Repair motors", description: nil)
    create(:related_instruction, occupation_standard: baseline, title: "Safety procedures", description: nil)
    convert("workProcesses" => [{"title" => "Maintain pumps and repair motors"}],
      "relatedInstructions" => [{"title" => "Safety"}, {"title" => "Procedures"}])

    row = report_row(baseline)
    expect(row["id"]).to eq "https://admin.apprenticeshipstandards.org/admin/occupation_standards/#{baseline.id}"
    expect(row["registration_agency_name"]).to eq baseline.registration_agency.to_s
    expect(row["source_pdf_occupation_scope"]).to eq "single"
    expect(row["baseline_title"]).to eq baseline.title
    expect(row.headers).not_to include("ai_id", "ai_title")
    expect(row["title"]).to eq "1"
    expect(row["work_processes"]).to eq "2"
    expect(row["instructions"]).to eq "2"
    expect(row["total_points"]).to eq "11"
    expect(row["total_percentage"]).to eq "100.0"
  end

  it "distinguishes missing content from present but differing content" do
    create(:work_process, occupation_standard: baseline, title: "Maintain pumps", description: nil)
    create(:related_instruction, occupation_standard: baseline, title: "Safety procedures", description: nil)
    convert("relatedInstructions" => [{"title" => "Accounting"}])
    actual.update!(onet_code: nil, title: "Accountant")

    row = report_row(baseline)
    expect(row["title"]).to eq "0"
    expect(row["onet_code"]).to eq "0"
    expect(row["work_processes"]).to eq "0"
    expect(row["instructions"]).to eq "1"
    expect(row["total_points"]).to eq "6"
    expect(row["total_percentage"]).to eq "54.55"
  end

  it "awards not-applicable content points only when a successful conversion exists" do
    expect(report_row(baseline)["total_points"]).to eq "0"
    convert
    expect(report_row(baseline)["work_processes"]).to eq "2"
    expect(report_row(baseline)["instructions"]).to eq "2"
  end

  it "compares an AI-selected row against its source baseline" do
    convert
    expect(report_row(actual)["id"]).to eq "https://admin.apprenticeshipstandards.org/admin/occupation_standards/#{actual.id}"
    expect(report_row(actual)["baseline_title"]).to eq baseline.title
    expect(report_row(actual)["total_points"]).to eq "11"
  end

  it "does not compare an AI row against itself or choose an ambiguous baseline" do
    convert
    create(:data_import, import: baseline.data_imports.first.import, occupation_standard: create(:occupation_standard))
    expect(report_row(actual)["source_pdf_occupation_scope"]).to eq "multiple"
    expect(report_row(actual)["total_points"]).to eq "0"
  end

  it "reports unknown when no PDF provenance is available" do
    expect(report_row(create(:occupation_standard))["source_pdf_occupation_scope"]).to eq "unknown"
  end

  it "does not count repeated data imports as additional occupations" do
    create(:data_import, import: baseline.data_imports.first.import, occupation_standard: baseline)
    expect(report_row(baseline)["source_pdf_occupation_scope"]).to eq "single"
  end

  it "includes competencies regardless of process boundaries" do
    process = create(:work_process, occupation_standard: baseline, title: "Repair motors", description: nil)
    create(:competency, work_process: process, title: "Inspect pumps")
    convert("workProcesses" => [{"title" => "Repair motors inspect pumps"}])
    expect(report_row(baseline)["work_processes"]).to eq "2"
  end
end
