require "digest"

# Applies a reviewed replacement to the existing PDF import. Checksums bind the
# repair to the exact source, old PDF, and replacement that were inspected.
class RepairEmbeddedImportPdf
  class UnsafeRepair < StandardError; end

  def self.call(pdf:, replacement_path:, source_sha256:, original_sha256:, replacement_sha256:, dry_run: true)
    raise UnsafeRepair, "Expected a PDF with a Word parent" unless pdf.is_a?(Imports::Pdf) && [Imports::Doc, Imports::Docx].any? { |type| pdf.parent.is_a?(type) }

    replacement_bytes = File.binread(replacement_path)
    verify_digest!(replacement_bytes, replacement_sha256, "replacement")
    reader = PDF::Reader.new(StringIO.new(replacement_bytes))
    raise UnsafeRepair, "Replacement PDF has no text" if reader.pages.empty? || reader.pages.all? { |page| page.text.blank? }

    pdf.with_lock do
      source = pdf.parent.reload
      verify_digest!(source.file.download, source_sha256, "source")
      if pdf.metadata&.dig("embedded_document_repair", "replacement_sha256") == replacement_sha256
        verify_digest!(pdf.file.download, replacement_sha256, "repaired PDF")
        return :already_repaired
      end

      raise UnsafeRepair, "A previous repair already exists" if pdf.metadata&.key?("embedded_document_repair")
      raise UnsafeRepair, "Redacted/private PDFs require separate review" if pdf.redacted_pdf.attached? || !(pdf.public_document? || pdf.import_root.public_document?)

      original_blob = pdf.file.blob
      verify_digest!(original_blob.download, original_sha256, "original PDF")
      return :would_repair if dry_run

      pdf.file.attach(io: StringIO.new(replacement_bytes), filename: "#{File.basename(source.filename, ".*")}-attachment.pdf", content_type: "application/pdf")
      pdf.update!(metadata: (pdf.metadata || {}).merge("embedded_document_repair" => {
        "source_blob_id" => source.file.blob.id,
        "source_sha256" => source_sha256,
        "original_sha256" => original_sha256,
        "replacement_sha256" => replacement_sha256,
        "repaired_at" => Time.current.iso8601
      }))
      :repaired
    end
  end

  def self.verify_digest!(bytes, expected, label)
    unless expected.present? && Digest::SHA256.hexdigest(bytes) == expected
      raise UnsafeRepair, "Checksum mismatch for #{label}"
    end
  end
  private_class_method :verify_digest!
end
