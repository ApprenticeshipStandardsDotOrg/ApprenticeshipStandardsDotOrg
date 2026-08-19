require "csv"

class OccupationStandardSampleSetReport
  HEADERS = %w[
    id
    title
    state
    state_registered
    agency_type
    ojt_type
    source
    organization
    has_org
    onet_code
    rapids_code
    import_user
    converted_at
    ai_converted_at
    manual_wp_count
    manual_skill_count
    manual_ojt_hours
    manual_ri_count
    manual_ri_hours
    ai_wp_count
    ai_skill_count
    ai_ojt_hours
    ai_ri_count
    ai_ri_hours
    score_wp_count
    score_skill_count
    score_ojt_hours
    score_ri_count
    score_ri_hours
    score_wp_text
    score_skill_text
    score_ri_text
  ].freeze

  def initialize(relation, filters:)
    @scope = OccupationStandard
      .where(id: relation.select(:id).distinct)
      .includes(
        :organization,
        :open_ai_import,
        data_imports: [
          :user,
          {import: :open_ai_import}
        ],
        registration_agency: :state,
        related_instructions: [],
        work_processes: :competencies
      )
    @filters = filters
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << HEADERS
      scope.find_each do |occupation_standard|
        csv << row(occupation_standard)
      end
    end
  end

  private

  attr_reader :scope, :filters

  def row(occupation_standard)
    manual = ManualSummary.new(occupation_standard)
    open_ai_import = open_ai_import_for(occupation_standard)
    ai = AISummary.new(open_ai_import&.parsed_response || {})

    [
      occupation_standard.id,
      occupation_standard.title,
      occupation_standard.state&.abbreviation,
      occupation_standard.state.present?,
      occupation_standard.registration_agency&.agency_type,
      occupation_standard.ojt_type,
      occupation_standard.source,
      occupation_standard.organization&.title,
      occupation_standard.organization.present?,
      occupation_standard.onet_code,
      occupation_standard.rapids_code,
      manual.import_user,
      manual.converted_at,
      open_ai_import&.created_at,
      manual.work_process_count,
      manual.skill_count,
      manual.ojt_hours,
      manual.related_instruction_count,
      manual.related_instruction_hours,
      ai.work_process_count,
      ai.skill_count,
      ai.ojt_hours,
      ai.related_instruction_count,
      ai.related_instruction_hours,
      numeric_score(manual.work_process_count, ai.work_process_count),
      numeric_score(manual.skill_count, ai.skill_count),
      numeric_score(manual.ojt_hours, ai.ojt_hours),
      numeric_score(manual.related_instruction_count, ai.related_instruction_count),
      numeric_score(manual.related_instruction_hours, ai.related_instruction_hours),
      text_score(manual.work_process_text, ai.work_process_text),
      text_score(manual.skill_text, ai.skill_text),
      text_score(manual.related_instruction_text, ai.related_instruction_text)
    ]
  end

  def open_ai_import_for(occupation_standard)
    occupation_standard.open_ai_import ||
      occupation_standard.source_imports.filter_map(&:open_ai_import).max_by(&:created_at)
  end

  def numeric_score(expected, actual)
    expected = expected.to_i
    actual = actual.to_i

    return "N/A" if expected.zero? && actual.zero?
    return 0.0 if expected.zero? || actual.zero?

    (([expected, actual].min.to_f / [expected, actual].max) * 100).round(2)
  end

  def text_score(expected, actual)
    expected_tokens = tokenize(expected)
    actual_tokens = tokenize(actual)

    return "N/A" if expected_tokens.empty? && actual_tokens.empty?
    return 0.0 if expected_tokens.empty? || actual_tokens.empty?

    ((expected_tokens.intersection(actual_tokens).count.to_f / expected_tokens.count) * 100).round(2)
  end

  def tokenize(text)
    text.to_s.downcase.scan(/[a-z0-9]+/).uniq
  end

  class ManualSummary
    def initialize(occupation_standard)
      @occupation_standard = occupation_standard
    end

    def import_user
      data_import&.user&.email || data_import&.user&.name
    end

    def converted_at
      data_import&.updated_at
    end

    def work_process_count
      work_processes.length
    end

    def skill_count
      work_processes.sum(&:competencies_count)
    end

    def ojt_hours
      work_processes.sum { |work_process| work_process.hours.to_i }
    end

    def related_instruction_count
      related_instructions.length
    end

    def related_instruction_hours
      related_instructions.sum { |related_instruction| related_instruction.hours.to_i }
    end

    def work_process_text
      work_processes.map { |work_process| [work_process.title, work_process.description].compact.join(" ") }.join(" ")
    end

    def skill_text
      work_processes.flat_map(&:competencies).map(&:title).join(" ")
    end

    def related_instruction_text
      related_instructions.map { |instruction| [instruction.title, instruction.description].compact.join(" ") }.join(" ")
    end

    private

    attr_reader :occupation_standard

    def data_import
      occupation_standard.data_imports.max_by(&:updated_at)
    end

    def work_processes
      occupation_standard.work_processes
    end

    def related_instructions
      occupation_standard.related_instructions
    end
  end

  class AISummary
    def initialize(response)
      @response = response || {}
    end

    def work_process_count
      work_processes.count
    end

    def skill_count
      work_processes.sum { |work_process| competencies(work_process).count }
    end

    def ojt_hours
      work_processes.sum do |work_process|
        integer_value(work_process, "maximumHours", "maximum_hours", "minimumHours", "minimum_hours", "defaultHours", "default_hours")
      end
    end

    def related_instruction_count
      related_instructions.count
    end

    def related_instruction_hours
      related_instructions.sum { |instruction| integer_value(instruction, "hours") }
    end

    def work_process_text
      work_processes.map { |work_process| text_value(work_process, "title", "description") }.join(" ")
    end

    def skill_text
      work_processes.flat_map { |work_process| competencies(work_process) }.map do |competency|
        competency.is_a?(Hash) ? value(competency, "title", "description") : competency
      end.join(" ")
    end

    def related_instruction_text
      related_instructions.map { |instruction| text_value(instruction, "title", "description") }.join(" ")
    end

    private

    attr_reader :response

    def work_processes
      Array(value(response, "workProcesses", "work_processes"))
    end

    def related_instructions
      Array(value(response, "relatedInstructions", "related_instructions"))
    end

    def competencies(work_process)
      Array(value(work_process, "competencies", "skills"))
    end

    def integer_value(hash, *keys)
      value(hash, *keys).to_i
    end

    def value(hash, *keys)
      return unless hash.respond_to?(:[])

      keys.lazy.map { |key| hash[key] }.find(&:present?)
    end

    def text_value(hash, *keys)
      return "" unless hash.respond_to?(:[])

      keys.filter_map { |key| hash[key].presence }.join(" ")
    end
  end
end
