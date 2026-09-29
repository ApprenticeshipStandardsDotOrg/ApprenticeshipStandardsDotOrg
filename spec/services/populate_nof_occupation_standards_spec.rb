require "rails_helper"

RSpec.describe PopulateNofOccupationStandards do
  subject(:result) do
    described_class.call(
      nofs_source: file_fixture("nofs-test.csv").to_s,
      bulletins_source: file_fixture("scraper/bulletins-results.csv").to_s,
      dry_run: dry_run
    )
  end

  let(:dry_run) { false }
  let!(:open_ai_prompt) { create(:open_ai_prompt, default: true) }
  let(:bulletin_uri) do
    "https://www.apprenticeship.gov/sites/default/files/bulletins/" \
      "Bulletin%202023-52%20New%20NGS%20AFSA.docx"
  end

  before do
    allow(PdfReaderJob).to receive(:perform_later)
    allow(CreateImportFromUri).to receive(:call)
  end

  it "reports an occupation standard already linked to the bulletin" do
    root = create(:standards_import, name: bulletin_uri)
    pdf = create(:imports_pdf, parent: root)
    standard = create(:occupation_standard, title: "Fire Sprinkler Installer")
    create(:open_ai_import, import: pdf, occupation_standard: standard)

    expect(entry_for(result, "Fire Sprinkler Installer")["Status"]).to eq "already_populated"
    expect(PdfReaderJob).not_to have_received(:perform_later)
  end

  it "enqueues an unconverted PDF from an existing bulletin import" do
    root = create(:standards_import, name: bulletin_uri)
    pdf = create(:imports_pdf, parent: root)

    entry = entry_for(result, "Fire Sprinkler Installer")
    expect(entry["Status"]).to eq("enqueued"), entry.inspect
    expect(PdfReaderJob).to have_received(:perform_later).with(
      import_id: pdf.id,
      open_ai_prompt: open_ai_prompt,
      force: false
    )
  end

  it "does not create imports or enqueue jobs during a dry run" do
    allow(CreateImportFromUri).to receive(:call)
    allow(PdfReaderJob).to receive(:perform_later)

    dry_run_result = described_class.call(
      nofs_source: file_fixture("nofs-test.csv").to_s,
      bulletins_source: file_fixture("scraper/bulletins-results.csv").to_s,
      dry_run: true
    )

    expect(entry_for(dry_run_result, "Fire Sprinkler Installer")["Status"]).to eq "would_create_import"
    expect(CreateImportFromUri).not_to have_received(:call)
    expect(PdfReaderJob).not_to have_received(:perform_later)
  end

  it "summarizes rows that cannot be populated from the bulletin export" do
    expect(entry_for(result, "No Bulletin Occupation")["Status"]).to eq "missing_bulletin"
    expect(entry_for(result, "Unknown Bulletin Occupation")["Status"]).to eq "missing_bulletin_result"
  end

  it "recognizes a strong title match when no bulletin was provided" do
    create(:occupation_standard, title: "No Bulletin Occupation")

    expect(entry_for(result, "No Bulletin Occupation")["Status"]).to eq "already_populated"
  end

  def entry_for(result, occupation)
    result.entries.find { |entry| entry["Occupation"] == occupation }
  end
end
