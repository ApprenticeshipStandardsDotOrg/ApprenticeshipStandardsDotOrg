require "digest"

# Explicitly refreshes prior attempts after a verified PDF repair. Successful
# refreshes keep the existing AI standard UUID; manual standards are never edited.
class ReconvertRepairedPdfWithAI < ConvertPdfImportWithAI
  def call
    checksum = verify_repaired_pdf!
    attempt = import.open_ai_import
    return skipped("No prior AI conversion") unless attempt
    return skipped("Already converted from this repaired PDF") if refreshed?(checksum)

    import.open_ai_imports.reload.filter_map(&:occupation_standard).each { |standard| verify_ai_standard!(standard) }
    result = ConvertPdfImportWithAI.new(import: import, open_ai_prompt: open_ai_prompt, force: true).call
    if result.created
      import.with_lock do
        raise "PDF changed during conversion" unless verify_repaired_pdf! == checksum

        repair = import.metadata.fetch("embedded_document_repair").merge("ai_conversion_sha256" => checksum, "ai_converted_at" => Time.current.iso8601)
        import.update!(metadata: import.metadata.merge("embedded_document_repair" => repair))
      end
    end
    result
  end

  private

  def verify_repaired_pdf!
    checksum = import.metadata&.dig("embedded_document_repair", "replacement_sha256")
    unless checksum.present? && Digest::SHA256.hexdigest(import.file.download) == checksum
      raise "PDF does not match the recorded embedded-document repair"
    end
    checksum
  end

  def verify_ai_standard!(standard)
    unless standard.source_ai_conversion? && !standard.data_imports.exists?
      raise "Refusing to overwrite a manual/imported occupation standard"
    end
  end

  def refreshed?(checksum)
    import.metadata.dig("embedded_document_repair", "ai_conversion_sha256") == checksum
  end

  def skipped(message)
    Result.new(open_ai_import: import.open_ai_import, occupation_standard: import.open_ai_import&.occupation_standard, created: false, errors: [message])
  end
end
