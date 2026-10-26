require "rails_helper"

RSpec.describe RemoveEmbeddedPdfBackup do
  let(:pdf) { create(:imports_pdf) }
  let(:original) { ActiveStorage::Blob.create_and_upload!(io: StringIO.new("old PDF"), filename: "old.pdf") }
  let!(:backup) { ActiveStorage::Attachment.create!(record: pdf, name: "file_before_embedded_repair", blob: original) }

  before do
    pdf.update!(metadata: {"embedded_document_repair" => {
      "original_blob_id" => original.id,
      "original_sha256" => Digest::SHA256.hexdigest(original.download),
      "replacement_sha256" => Digest::SHA256.hexdigest(pdf.file.download)
    }})
  end

  it "defaults to a dry run" do
    expect(described_class.call(pdf: pdf)).to eq :would_remove
    expect(backup.reload).to be_persisted
  end

  it "purges only the backup and supports repeated cleanup" do
    current = pdf.file.blob

    expect(described_class.call(pdf: pdf, dry_run: false)).to eq :removed

    expect(ActiveStorage::Blob.exists?(original.id)).to be false
    expect(pdf.reload.file.blob).to eq current
    expect(described_class.call(pdf: pdf, dry_run: false)).to eq :already_removed
  end

  it "keeps an old blob still referenced by another record" do
    other = create(:imports_pdf)
    other.file.attach(original)

    described_class.call(pdf: pdf, dry_run: false)

    expect(other.reload.file.download).to eq "old PDF"
  end

  it "refuses to remove a backup when the repaired PDF no longer matches" do
    pdf.update!(metadata: {"embedded_document_repair" => {"replacement_sha256" => "wrong"}})

    expect { described_class.call(pdf: pdf, dry_run: false) }.to raise_error(RepairEmbeddedImportPdf::UnsafeRepair)
    expect(backup.reload).to be_persisted
  end
end
