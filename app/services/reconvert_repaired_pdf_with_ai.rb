require "digest"

# Explicitly refreshes prior attempts after a verified PDF repair. Successful
# refreshes keep the existing AI standard UUID; manual standards are never edited.
class ReconvertRepairedPdfWithAI < ConvertPdfImportWithAI
  EXTRACTED_FIELDS = %w[title existing_title onet_code rapids_code ojt_type national_standard_type registration_date].freeze

  def call
    checksum = verify_repaired_pdf!
    attempt = import.open_ai_import
    return skipped("No prior AI conversion") unless attempt
    return skipped("Already converted from this repaired PDF") if refreshed?(checksum)

    standard = attempt.occupation_standard
    verify_ai_standard!(standard) if standard
    raw_response = generate_response
    begin
      parsed_response = parse_response(raw_response)
      candidate = build_occupation_standard(parsed_response)
      errors = extraction_errors(parsed_response, candidate)
      if standard&.rapids_code.present? && candidate.rapids_code.present? && standard.rapids_code != candidate.rapids_code
        errors << "Extracted RAPIDS code differs from the existing AI standard"
      end
    rescue JSON::ParserError => error
      parsed_response = {}
      errors = ["OpenAI response was not valid JSON: #{error.message}"]
    end

    import.with_lock do
      raise "PDF changed during conversion" unless verify_repaired_pdf! == checksum
      return skipped("Already converted from this repaired PDF") if refreshed?(checksum)

      attempt.lock!
      raise "AI standard link changed during conversion" unless attempt.occupation_standard_id == standard&.id

      if standard
        standard.lock!
        verify_ai_standard!(standard)
      end
      attempt.update!(response: raw_response.presence || "{}", parsed_response: parsed_response, extraction_errors: errors)
      if errors.empty?
        if standard
          standard.work_processes.destroy_all
          standard.related_instructions.destroy_all
          standard.assign_attributes(candidate.attributes.slice(*EXTRACTED_FIELDS))
          [:registration_agency, :occupation, :organization, :industry].each { |name| standard.public_send(:"#{name}=", candidate.public_send(name)) }
          standard.work_processes = candidate.work_processes.to_a
          standard.related_instructions = candidate.related_instructions.to_a
          standard.updated_at = Time.current
          standard.save!
        else
          candidate.save!
          attempt.update!(occupation_standard: candidate)
          standard = candidate
        end
        repair = import.metadata.fetch("embedded_document_repair").merge("ai_conversion_sha256" => checksum, "ai_converted_at" => Time.current.iso8601)
        import.update!(status: :archived, metadata: import.metadata.merge("embedded_document_repair" => repair))
      end
      Result.new(open_ai_import: attempt, occupation_standard: standard, created: errors.empty?, errors: errors)
    end
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
