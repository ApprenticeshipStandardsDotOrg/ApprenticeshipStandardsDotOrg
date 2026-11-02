require "rails_helper"
require "csv"

RSpec.describe OccupationStandardOJTAuditReport do
  def setup_pair(expected:, actual:, text:)
    baseline = create(:occupation_standard, ojt_type: expected)
    pdf = create(:imports_pdf)
    create(:data_import, import: pdf, occupation_standard: baseline)
    ai = create(:occupation_standard, source: :ai_conversion, ojt_type: actual)
    create(:open_ai_import, import: pdf, occupation_standard: ai,
      parsed_response: {"documentOccupationCount" => 1, "singleOccupation" => true})
    allow(PdfTextExtractor).to receive(:new).and_return(instance_double(PdfTextExtractor, call: text))
    baseline
  end

  def row_for(baseline)
    csv = described_class.new(OccupationStandard.where(id: baseline.id), filters: {}).to_csv
    CSV.parse(csv, headers: true).first
  end

  it "reports a baseline conflict without changing either record or calling AI" do
    baseline = setup_pair(expected: :competency, actual: :time, text: "☒ Time-based ☐ Competency-based ☐ Hybrid")
    expect(ChatGptGenerateText).not_to receive(:new)

    row = row_for(baseline)

    expect(row["classification"]).to eq "baseline_source_conflict"
    expect(row["source_ojt_type"]).to eq "time"
    expect(JSON.parse(row["evidence"]).first).to include("page" => 1)
    expect(row["id"]).to include baseline.id
    expect(baseline.reload.ojt_type).to eq "competency"
    expect(baseline.source_imports.first.ai_import_for(baseline).occupation_standard.ojt_type).to eq "time"
  end

  it "reports a source-supported AI error" do
    baseline = setup_pair(expected: :competency, actual: :hybrid, text: "☐ Time-based ☒ Competency-based ☐ Hybrid")

    expect(row_for(baseline)["classification"]).to eq "ai_source_conflict"
  end

  it "requires review when a linked PDF has multiple baseline occupations" do
    baseline = setup_pair(expected: :time, actual: :hybrid, text: "☒ Time-based ☐ Competency-based ☐ Hybrid")
    create(:data_import, import: baseline.source_imports.first, occupation_standard: create(:occupation_standard))

    expect(row_for(baseline)["classification"]).to eq "needs_review"
  end

  it "reports missing conversions without guessing a source approach" do
    baseline = create(:occupation_standard)

    expect(row_for(baseline)["classification"]).to eq "missing_ai_conversion"
  end
end
