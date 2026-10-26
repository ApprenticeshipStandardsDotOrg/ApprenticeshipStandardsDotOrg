class ConvertPdfImportWithAI
  Result = Data.define(:open_ai_import, :occupation_standard, :created, :errors) do
    def occupation_standards
      open_ai_import&.import&.open_ai_imports&.select { |attempt| attempt.extraction_errors.empty? }&.filter_map(&:occupation_standard)&.uniq || []
    end
  end

  def initialize(import:, open_ai_prompt: OpenAIPrompt.default, force: false)
    @import = import
    @open_ai_prompt = open_ai_prompt
    @force = force
  end

  def call
    return existing_result if !force && import.open_ai_imports.any?

    source_blob_id = import.file.blob.id
    raw_response = generate_response
    parsed_response = parse_response(raw_response)
    persist_document(raw_response, parsed_response, source_blob_id)
  rescue JSON::ParserError => error
    store_document_error(raw_response, {}, ["OpenAI response was not valid JSON: #{error.message}"])
  end

  private

  attr_reader :import, :open_ai_prompt, :force

  def clear_failed_attempt
    import.open_ai_imports.where(occupation_standard_id: nil).destroy_all
    import.reload
  end

  def persist_document(raw_response, response, source_blob_id)
    return store_document_error(raw_response, {}, ["OpenAI response must be a JSON object"]) unless response.is_a?(Hash)

    entries = response["occupations"]
    if response.key?("occupations") && (!entries.is_a?(Array) || entries.empty? || entries.any? { |entry| !entry.is_a?(Hash) })
      return store_document_error(raw_response, response, ["occupations must contain complete occupation objects"])
    end
    separated = entries.is_a?(Array)
    entries ||= [response]
    import.with_lock do
      raise "PDF changed during conversion" unless import.file.blob.id == source_blob_id

      return existing_result if !force && import.open_ai_imports.any?

      clear_failed_attempt if force
      existing = import.open_ai_imports.includes(:occupation_standard).to_a
      attempts = []
      errors = []
      identities = []
      entries.each do |entry|
        occupation_response = separated ? separate_response(response, entry) : entry
        candidate = build_occupation_standard(occupation_response)
        entry_errors = extraction_errors(occupation_response, candidate, separated: separated)
        identity = [MatchAIOccupation.normalize_code(candidate.rapids_code), MatchAIOccupation.normalize_title(candidate.title),
          entry["appendixLabel"], candidate.organization&.title, candidate.registration_agency_id]
        entry_errors << "Duplicate occupation section" if separated && identities.include?(identity)
        identities << identity
        matched = MatchAIOccupation.call(existing.reject { |attempt| attempts.include?(attempt) }, candidate, allow_single_fallback: false, occupation_response: occupation_response)
        linked = existing.select { |attempt| attempt.occupation_standard_id.present? }
        if entries.one? && linked.one? && !matched && candidate.rapids_code.present? && linked.first.occupation_standard.rapids_code.present?
          entry_errors << "Extracted RAPIDS code differs from the existing AI standard"
          matched = linked.first
        end
        if matched && candidate.rapids_code.present? && matched.occupation_standard.rapids_code.present? &&
            MatchAIOccupation.normalize_code(candidate.rapids_code)[/\A\d+/] != MatchAIOccupation.normalize_code(matched.occupation_standard.rapids_code)[/\A\d+/] &&
            MatchAIOccupation.normalize_title(candidate.title) != MatchAIOccupation.normalize_title(matched.occupation_standard.title)
          entry_errors << "Extracted RAPIDS code differs from the existing AI standard" unless entry_errors.include?("Extracted RAPIDS code differs from the existing AI standard")
        end
        attempt = matched || OpenAIImport.new(import: import)
        attempt.update!(response: raw_response, parsed_response: occupation_response, extraction_errors: entry_errors)
        PersistAIOccupation.call(attempt: attempt, candidate: candidate) if entry_errors.empty?
        attempts << attempt
        errors.concat(entry_errors.map { |error| separated ? "#{candidate.title.presence || "Occupation #{attempts.size}"}: #{error}" : error })
      end
      declared_count = integer_value(response, "documentOccupationCount")
      if separated && declared_count && declared_count != entries.size
        message = "Occupation inventory/extraction count mismatch: expected #{declared_count}, received #{entries.size}"
        attempts << OpenAIImport.create!(import: import, response: raw_response, parsed_response: response, extraction_errors: [message])
        errors << message
      end
      (existing - attempts).each do |attempt|
        next unless attempt.occupation_standard_id

        message = "Previously converted occupation was not found in the latest extraction"
        attempt.update!(extraction_errors: [message])
        errors << "#{attempt.occupation_standard.title}: #{message}"
      end
      standard = attempts.filter_map(&:occupation_standard).first
      if errors.empty?
        import.archived!
      elsif standard
        import.needs_human_review!
      end
      Result.new(open_ai_import: attempts.first, occupation_standard: standard, created: errors.empty?, errors: errors)
    end
  end

  def separate_response(document, entry)
    shared_keys = %w[organization registrationAgency state registrationAgencyType registrationState nationalStandardType registrationDate]
    document.slice(*shared_keys).merge(entry).merge(
      "documentOccupationCount" => document["documentOccupationCount"] || document["occupations"].size,
      "singleOccupation" => document["occupations"].one?,
      "selectedOccupationTitle" => entry["title"],
      "extractionWarnings" => (Array(document["extractionWarnings"]) + Array(entry["extractionWarnings"])).uniq,
      "occupationInventory" => [entry.slice("title", "existingTitle", "onetCode", "rapidsCode", "ojtType", "appendixLabel", "pageNumbers")]
    )
  end

  def store_document_error(raw_response, response, errors)
    import.with_lock do
      attempt = import.open_ai_imports.first || OpenAIImport.new(import: import)
      attempt.update!(response: raw_response.presence || "{}", parsed_response: response, extraction_errors: errors)
      Result.new(open_ai_import: attempt, occupation_standard: attempt.occupation_standard, created: false, errors: errors)
    end
  end

  def existing_result
    attempt = import.open_ai_imports.detect { |record| record.occupation_standard_id.present? && record.extraction_errors.empty? } || import.open_ai_imports.first
    Result.new(
      open_ai_import: attempt,
      occupation_standard: attempt&.occupation_standard,
      created: false,
      errors: ["Import has already been converted with AI"]
    )
  end

  def generate_response
    ChatGptGenerateText.new("#{open_ai_prompt.prompt} #{pdf_text}").call
  end

  def pdf_text
    PdfTextExtractor.new(import.file).call
  end

  def parse_response(raw_response)
    JSON.parse(raw_response)
  end

  def build_occupation_standard(response)
    OccupationStandard.new(
      title: title(response),
      existing_title: existing_title(response),
      onet_code: onet_code(response),
      rapids_code: rapids_code(response),
      ojt_type: ojt_type(response),
      registration_agency: registration_agency(response),
      national_standard_type: national_standard_type(response),
      organization: organization(response),
      occupation: occupation(response),
      industry: industry(response),
      registration_date: parse_date(value(response, "registrationDate", "registration_date")),
      source: :ai_conversion,
      work_processes: work_processes(response),
      related_instructions: related_instructions(response)
    )
  end

  def extraction_errors(response, occupation_standard, separated: false)
    errors = []
    errors << "PDF appears to contain multiple occupations" if !separated && multiple_occupations?(response)
    errors << "Could not extract title" if occupation_standard.title.blank?
    errors << "Could not extract OJT type" if occupation_standard.ojt_type.blank?
    errors << registration_agency_error(response) if occupation_standard.registration_agency.blank?

    if occupation_standard.invalid?
      errors.concat(occupation_standard.errors.full_messages)
    end

    errors.compact.uniq
  end

  def multiple_occupations?(response)
    count = integer_value(response, "documentOccupationCount", "document_occupation_count", "occupationCount", "occupation_count")
    return true if count.to_i > 1

    single_occupation = value(response, "singleOccupation", "single_occupation")
    single_occupation == false || single_occupation.to_s.match?(/\Afalse\z/i)
  end

  def registration_agency_error(response)
    [
      "Could not resolve registration agency",
      "state: #{value(response, "registrationState", "state", "State").presence || "missing"}",
      "agency type: #{registration_agency_type(response).presence || "missing"}"
    ].join(" - ")
  end

  def value(hash, *keys)
    return unless hash.respond_to?(:[])

    keys.lazy.map { |key| hash[key] || hash[key.to_sym] }.find(&:present?)
  end

  def integer_value(hash, *keys)
    raw_value = value(hash, *keys)
    return if raw_value.blank?

    match = raw_value.to_s.delete(",").match(/\d+/)
    match[0].to_i if match
  end

  def onet_code(response)
    value(response, "onetCode", "onet_code", "Onet Code", "O*NET Code") ||
      value(selected_occupation(response), "onetCode", "onet_code", "O*NET Code")
  end

  def rapids_code(response)
    rapids = value(response, "rapidsCode", "rapids_code", "RAPIDS Code") ||
      value(selected_occupation(response), "rapidsCode", "rapids_code", "RAPIDS Code")
    return if rapids.blank?

    code = rapids.to_s.strip.upcase.delete(" ")
    match = code.match(/\A(?<digits>\d+)(?<suffix>[A-Z]*)\z/)
    return code unless match

    "#{match[:digits].rjust(4, "0")}#{match[:suffix]}"
  end

  def ojt_type(response)
    case (value(response, "ojtType", "ojt_type", "Type") ||
      value(selected_occupation(response), "ojtType", "ojt_type", "Type")).to_s
    when /competency/i
      :competency
    when /time|hour/i
      :time
    when /hybrid/i
      :hybrid
    end
  end

  def title(response)
    value(response, "title", "Title") ||
      value(response, "selectedOccupationTitle", "selected_occupation_title") ||
      value(selected_occupation(response), "title", "Title")
  end

  def existing_title(response)
    value(response, "existingTitle", "existing_title", "Existing Title") ||
      value(selected_occupation(response), "existingTitle", "existing_title", "Existing Title")
  end

  def selected_occupation(response)
    inventory = Array(value(response, "occupationInventory", "occupation_inventory"))
    selected_title = value(response, "selectedOccupationTitle", "selected_occupation_title").to_s
    return inventory.first if inventory.one?

    inventory.find do |occupation|
      value(occupation, "title", "Title").to_s == selected_title
    end
  end

  def registration_agency(response)
    state = registration_state(response)
    agency_type = registration_agency_type(response)

    if state && agency_type
      RegistrationAgency.registration_agency_for_state(state, requested_agency_type: agency_type) ||
        single_registration_agency_for_state(state)
    elsif state
      RegistrationAgency.registration_agency_for_state(state, requested_agency_type: :oa) ||
        single_registration_agency_for_state(state)
    elsif national_standard?(response)
      RegistrationAgency.find_by(state: nil, agency_type: agency_type.presence || :oa)
    else
      RegistrationAgency.registration_agency_for_national_program
    end
  end

  def single_registration_agency_for_state(state)
    agencies = RegistrationAgency.where(state: state).to_a
    agencies.one? ? agencies.first : nil
  end

  def registration_state(response)
    state_value = value(response, "registrationState", "state", "State")
    return if state_value.blank?

    State.find_by(abbreviation: state_value.to_s.upcase) ||
      State.find_by("LOWER(name) = ?", state_value.to_s.downcase)
  end

  def registration_agency_type(response)
    agency = value(response, "registrationAgencyType", "registrationAgency", "registration_agency", "OA or SAA")

    case agency.to_s
    when /saa|state apprenticeship agency/i
      :saa
    when /oa|office of apprenticeship|national/i
      :oa
    end
  end

  def national_standard?(response)
    registration_state(response).blank? &&
      (
        value(response, "national", "National").present? ||
        value(response, "nationalStandardType", "national_standard_type").present?
      )
  end

  def national_standard_type(response)
    return unless national_standard?(response)

    type = value(response, "nationalStandardType", "national_standard_type", "National")
    return if type.blank?

    normalized = type.to_s.downcase.gsub(/\Anational\s*/, "").gsub(/\s+/, "_").singularize
    normalized if OccupationStandard.national_standard_types.key?(normalized)
  end

  def organization(response)
    title = value(response, "organization", "organizationName", "Sponsor Name")
    Organization.find_or_initialize_by(title: title) if title.present?
  end

  def occupation(response)
    Occupation.find_by(rapids_code: rapids_code(response)) || begin
      onet = Onet.find_by(code: onet_code(response))
      Occupation.find_by(onet: onet) if onet
    end
  end

  def industry(response)
    if onet_code(response).present? && (matches = onet_code(response).match(/\A(?<prefix>\d{2})/))
      Industry.find_by(prefix: matches[:prefix], version: Industry::CURRENT_VERSION)
    end
  end

  def parse_date(date)
    Date.parse(date.to_s) if date.present?
  rescue Date::Error
    nil
  end

  def work_processes(response)
    Array(value(
      response,
      "workProcesses",
      "work_processes",
      "workProcessSchedule",
      "work_process_schedule",
      "onTheJobTraining",
      "on_the_job_training",
      "onTheJobLearning",
      "on_the_job_learning",
      "ojt",
      "ojl"
    )).filter_map.with_index(1) do |work_process_response, index|
      title = value(
        work_process_response,
        "title",
        "name",
        "workProcess",
        "work_process",
        "workActivity",
        "work_activity",
        "task",
        "duty",
        "Work Process Title"
      )
      next if title.blank?

      default_hours = integer_value(work_process_response, "defaultHours", "default_hours", "default", "hours")
      minimum_hours = integer_value(work_process_response, "minimumHours", "minimum_hours", "minHours", "min_hours")
      maximum_hours = integer_value(
        work_process_response,
        "maximumHours",
        "maximum_hours",
        "maxHours",
        "max_hours",
        "estimatedHours",
        "estimated_hours",
        "hours"
      )

      WorkProcess.new(
        title: title,
        description: value(work_process_response, "description", "details", "Work Process Description"),
        default_hours: default_hours,
        minimum_hours: minimum_hours,
        maximum_hours: maximum_hours || default_hours,
        sort_order: index,
        competencies: competencies(work_process_response)
      )
    end
  end

  def competencies(work_process_response)
    Array(value(
      work_process_response,
      "competencies",
      "skills",
      "tasks",
      "duties",
      "performanceObjectives",
      "performance_objectives"
    )).filter_map.with_index(1) do |competency_response, index|
      title = if competency_response.is_a?(Hash)
        value(competency_response, "title", "name", "skill", "task", "duty", "description", "text")
      else
        competency_response
      end
      next if title.blank?

      Competency.new(title: title, sort_order: index)
    end
  end

  def related_instructions(response)
    Array(value(
      response,
      "relatedInstructions",
      "related_instructions",
      "relatedTechnicalInstruction",
      "related_technical_instruction",
      "classroomInstruction",
      "classroom_instruction",
      "rti",
      "rsi",
      "courses"
    )).filter_map.with_index(1) do |related_instruction_response, index|
      title = value(related_instruction_response, "title", "name", "course", "courseTitle", "course_title")
      next if title.blank?

      RelatedInstruction.new(
        title: title,
        description: value(related_instruction_response, "description", "details"),
        code: value(related_instruction_response, "code", "courseCode", "course_code"),
        hours: integer_value(related_instruction_response, "hours", "defaultHours", "default_hours", "estimatedHours", "estimated_hours"),
        organization: related_instruction_organization(related_instruction_response),
        sort_order: index
      )
    end
  end

  def related_instruction_organization(response)
    title = value(response, "organization", "provider", "institution")
    Organization.find_or_initialize_by(title: title) if title.present?
  end
end
