require "digest"

# Removes only backups created by the earlier embedded-document repair.
class RemoveEmbeddedPdfBackup
  def self.call(pdf:, dry_run: true)
    attachment = ActiveStorage::Attachment.find_by(record: pdf, name: "file_before_embedded_repair")
    return :already_removed unless attachment

    repair = pdf.metadata&.fetch("embedded_document_repair", nil)
    unless repair && repair["original_blob_id"] == attachment.blob_id &&
        attachment.blob_id != pdf.file.blob.id &&
        Digest::SHA256.hexdigest(pdf.file.download) == repair["replacement_sha256"] &&
        Digest::SHA256.hexdigest(attachment.download) == repair["original_sha256"]
      raise RepairEmbeddedImportPdf::UnsafeRepair, "Backup or replacement does not match the recorded repair"
    end
    return :would_remove if dry_run

    attachment.purge
    :removed
  end
end
