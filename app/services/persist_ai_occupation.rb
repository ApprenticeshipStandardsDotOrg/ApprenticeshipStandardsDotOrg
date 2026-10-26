class PersistAIOccupation
  EXTRACTED_FIELDS = %w[title existing_title onet_code rapids_code ojt_type national_standard_type registration_date].freeze

  def self.call(attempt:, candidate:)
    standard = attempt.occupation_standard
    if standard
      standard.lock!
      unless standard.source_ai_conversion? && !standard.data_imports.exists?
        raise "Refusing to overwrite a manual/imported occupation standard"
      end
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
    standard
  end
end
