class ConvertPdfImportWithAI
  Result = Data.define(:open_ai_import, :occupation_standard, :created, :errors)

  def initialize(import:, open_ai_prompt: OpenAIPrompt.default, force: false)
    @import = import
    @open_ai_prompt = open_ai_prompt
    @force = force
  end

  def call
    clear_failed_attempt if force
    return existing_result if import.open_ai_import

    raw_response = generate_response
    parsed_response = parse_response(raw_response)
    occupation_standard = build_occupation_standard(parsed_response)
    errors = extraction_errors(parsed_response, occupation_standard)

    OpenAIImport.transaction do
      open_ai_import = OpenAIImport.create!(
        import: import,
        response: raw_response,
        parsed_response: parsed_response,
        extraction_errors: errors
      )

      if errors.empty?
        occupation_standard.save!
        open_ai_import.update!(occupation_standard: occupation_standard)
        import.archived!
      end

      Result.new(
        open_ai_import: open_ai_import,
        occupation_standard: open_ai_import.occupation_standard,
        created: errors.empty?,
        errors: errors
      )
    end
  rescue JSON::ParserError => error
    open_ai_import = OpenAIImport.create!(
      import: import,
      response: raw_response,
      extraction_errors: ["OpenAI response was not valid JSON: #{error.message}"]
    )

    Result.new(
      open_ai_import: open_ai_import,
      occupation_standard: nil,
      created: false,
      errors: open_ai_import.extraction_errors
    )
  end

  private

  attr_reader :import, :open_ai_prompt, :force

  def clear_failed_attempt
    return unless import.open_ai_import&.occupation_standard_id.blank?

    import.open_ai_import.destroy!
    import.reload
  end

  def existing_result
    Result.new(
      open_ai_import: import.open_ai_import,
      occupation_standard: import.open_ai_import.occupation_standard,
      created: false,
      errors: ["Import has already been converted with AI"]
    )
  end

  def generate_response
    ChatGptGenerateText.new("#{open_ai_prompt.prompt} #{pdf_text}").call
  end

  def pdf_text
    import.file.open do |io|
      reader = PDF::Reader.new(io)
      reader.pages.map(&:text).to_s
    end
  end

  def parse_response(raw_response)
    JSON.parse(raw_response)
  end

  def build_occupation_standard(response)
    OccupationStandard.new(
      title: value(response, "title", "Title"),
      existing_title: value(response, "existingTitle", "existing_title", "Existing Title"),
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

  def extraction_errors(response, occupation_standard)
    errors = []
    errors << "Could not extract title" if occupation_standard.title.blank?
    errors << "Could not extract OJT type" if occupation_standard.ojt_type.blank?
    errors << registration_agency_error(response) if occupation_standard.registration_agency.blank?

    if occupation_standard.invalid?
      errors.concat(occupation_standard.errors.full_messages)
    end

    errors.compact.uniq
  end

  def registration_agency_error(response)
    [
      "Could not resolve registration agency",
      "state: #{value(response, "registrationState", "state", "State").presence || "missing"}",
      "agency type: #{registration_agency_type(response).presence || "missing"}"
    ].join(" - ")
  end

  def value(hash, *keys)
    keys.lazy.map { |key| hash[key] }.find(&:present?)
  end

  def onet_code(response)
    value(response, "onetCode", "onet_code", "Onet Code", "O*NET Code")
  end

  def rapids_code(response)
    rapids = value(response, "rapidsCode", "rapids_code", "RAPIDS Code")
    return if rapids.blank?

    code = rapids.to_s.strip.upcase.delete(" ")
    match = code.match(/\A(?<digits>\d+)(?<suffix>[A-Z]*)\z/)
    return code unless match

    "#{match[:digits].rjust(4, "0")}#{match[:suffix]}"
  end

  def ojt_type(response)
    case value(response, "ojtType", "ojt_type", "Type").to_s
    when /competency/i
      :competency
    when /time|hour/i
      :time
    when /hybrid/i
      :hybrid
    end
  end

  def registration_agency(response)
    state = registration_state(response)
    agency_type = registration_agency_type(response)

    if national_standard?(response)
      RegistrationAgency.find_by(state: nil, agency_type: agency_type.presence || :oa)
    elsif state && agency_type
      RegistrationAgency.find_by(state: state, agency_type: agency_type)
    elsif state
      RegistrationAgency.find_by(state: state, agency_type: :oa)
    else
      RegistrationAgency.registration_agency_for_national_program
    end
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
    value(response, "national", "National").present? ||
      value(response, "nationalStandardType", "national_standard_type").present?
  end

  def national_standard_type(response)
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
    Array(value(response, "workProcesses", "work_processes")).filter_map.with_index(1) do |work_process_response, index|
      title = value(work_process_response, "title", "Work Process Title")
      next if title.blank?

      WorkProcess.new(
        title: title,
        description: value(work_process_response, "description", "Work Process Description"),
        default_hours: value(work_process_response, "defaultHours", "default_hours"),
        minimum_hours: value(work_process_response, "minimumHours", "minimum_hours"),
        maximum_hours: value(work_process_response, "maximumHours", "maximum_hours"),
        sort_order: index,
        competencies: competencies(work_process_response)
      )
    end
  end

  def competencies(work_process_response)
    Array(value(work_process_response, "competencies")).filter_map.with_index(1) do |competency_response, index|
      title = competency_response.is_a?(Hash) ? value(competency_response, "title") : competency_response
      next if title.blank?

      Competency.new(title: title, sort_order: index)
    end
  end

  def related_instructions(response)
    Array(value(response, "relatedInstructions", "related_instructions")).filter_map.with_index(1) do |related_instruction_response, index|
      title = value(related_instruction_response, "title")
      next if title.blank?

      RelatedInstruction.new(
        title: title,
        description: value(related_instruction_response, "description"),
        code: value(related_instruction_response, "code"),
        hours: value(related_instruction_response, "hours"),
        organization: related_instruction_organization(related_instruction_response),
        sort_order: index
      )
    end
  end

  def related_instruction_organization(response)
    title = value(response, "organization")
    Organization.find_or_initialize_by(title: title) if title.present?
  end
end
