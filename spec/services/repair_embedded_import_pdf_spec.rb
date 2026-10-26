require "rails_helper"

RSpec.describe RepairEmbeddedImportPdf do
  let(:source) { create(:imports_doc, public_document: true) }
  let(:pdf) { create(:imports_pdf, parent: source, public_document: true) }
  let(:replacement_path) { Rails.root.join("spec/fixtures/files/pixel1x1_redacted.pdf") }
  let(:arguments) do
    {
      pdf: pdf, replacement_path: replacement_path,
      source_sha256: Digest::SHA256.hexdigest(source.file.download),
      original_sha256: Digest::SHA256.hexdigest(pdf.file.download),
      replacement_sha256: Digest::SHA256.file(replacement_path).hexdigest
    }
  end

  before do
    # The fixtures contain images; supply text while exercising the repair guards.
    allow_any_instance_of(PDF::Reader::Page).to receive(:text).and_return("Work process schedule")
  end

  it "defaults to a dry run without changing attachments or metadata" do
    blob = pdf.file.blob
    expect(described_class.call(**arguments)).to eq :would_repair
    expect(pdf.reload.file.blob).to eq blob
    expect(ActiveStorage::Attachment.where(record: pdf, name: "file_before_embedded_repair")).to be_empty
    expect(pdf.metadata).not_to have_key("embedded_document_repair")
  end

  it "replaces the PDF without retaining a backup and is idempotent" do
    original = pdf.file.blob
    data_import = create(:data_import, import: pdf)
    kwargs = arguments

    perform_enqueued_jobs(only: ActiveStorage::PurgeJob) do
      expect(described_class.call(**kwargs, dry_run: false)).to eq :repaired
    end

    pdf.reload
    expect(ActiveStorage::Attachment.where(record: pdf, name: "file_before_embedded_repair")).to be_empty
    expect(pdf.file.download).to eq File.binread(replacement_path)
    expect(data_import.reload.import_id).to eq pdf.id
    expect(described_class.call(**kwargs, dry_run: false)).to eq :already_repaired
    expect(ActiveStorage::Blob.exists?(original.id)).to be false
  end

  it "rejects a stale source or old PDF and an unreviewed replacement" do
    kwargs = arguments
    [:source_sha256, :original_sha256, :replacement_sha256].each do |key|
      expect { described_class.call(**kwargs.merge(key => "wrong"), dry_run: false) }
        .to raise_error(described_class::UnsafeRepair, /Checksum mismatch/)
    end
    expect(ActiveStorage::Attachment.where(record: pdf, name: "file_before_embedded_repair")).to be_empty
  end

  it "refuses to replace a redacted PDF" do
    pdf.redacted_pdf.attach(pdf.file.blob)

    expect { described_class.call(**arguments, dry_run: false) }
      .to raise_error(described_class::UnsafeRepair, /Redacted\/private/)
  end

  it "refuses a private source" do
    source.update!(public_document: false)
    source.import_root.update!(public_document: false)
    pdf.update!(public_document: false)

    expect { described_class.call(**arguments, dry_run: false) }
      .to raise_error(described_class::UnsafeRepair, /Redacted\/private/)
  end

  it "rejects an empty replacement PDF before changing attachments" do
    allow_any_instance_of(PDF::Reader::Page).to receive(:text).and_return("")

    expect { described_class.call(**arguments, dry_run: false) }
      .to raise_error(described_class::UnsafeRepair, /no text/)
    expect(ActiveStorage::Attachment.where(record: pdf, name: "file_before_embedded_repair")).to be_empty
  end
end
