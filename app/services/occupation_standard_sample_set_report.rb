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
    ai_document_occupation_count
    ai_single_occupation
    ai_selected_occupation_title
    source_pdf_standard_count
    baseline_oa_state_single_occupation
    manual_wp_count
    ai_wp_count
    manual_skill_count
    ai_skill_count
    manual_ojt_hours
    ai_ojt_hours
    manual_ri_count
    ai_ri_count
    manual_ri_hours
    ai_ri_hours
    score_wp_count
    score_skill_count
    score_ojt_hours
    score_ri_count
    score_ri_hours
    score_wp_text
    score_skill_text
    score_ri_text
    score_wp_names_match
    score_wp_hours_match
    score_competency_names_match
    score_ri_titles_match
    score_oa_single_occupation_success
    expected_work_processes
    actual_work_processes
    missing_work_process_names
    unexpected_work_process_names
    expected_competency_names
    actual_competency_names
    missing_competency_names
    unexpected_competency_names
    expected_related_instruction_titles
    actual_related_instruction_titles
    missing_related_instruction_titles
    unexpected_related_instruction_titles
    work_process_mismatch_category
    competency_mismatch_category
    related_instruction_mismatch_category
    baseline_duplicate_work_process_name_count
    baseline_work_process_titles_with_hours_count
    hierarchy_boundary_overlap_count
  ].freeze

  def initialize(relation, filters:)
    @scope = OccupationStandard
      .where(id: relation.select(:id).distinct)
      .includes(
        :organization,
        :open_ai_import,
        data_imports: [
          :user,
          {import: [:open_ai_import, :data_imports]}
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
    baseline_candidate = baseline_candidate?(occupation_standard, manual)

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
      ai.document_occupation_count,
      ai.single_occupation,
      ai.selected_occupation_title,
      manual.source_pdf_occupation_standard_count,
      boolean_value(baseline_candidate),
      manual.work_process_count,
      ai.work_process_count,
      manual.skill_count,
      ai.skill_count,
      manual.ojt_hours,
      ai.ojt_hours,
      manual.related_instruction_count,
      ai.related_instruction_count,
      manual.related_instruction_hours,
      ai.related_instruction_hours,
      numeric_score(manual.work_process_count, ai.work_process_count),
      numeric_score(manual.skill_count, ai.skill_count),
      numeric_score(manual.ojt_hours, ai.ojt_hours),
      numeric_score(manual.related_instruction_count, ai.related_instruction_count),
      numeric_score(manual.related_instruction_hours, ai.related_instruction_hours),
      text_score(manual.work_process_text, ai.work_process_text),
      text_score(manual.skill_text, ai.skill_text),
      text_score(manual.related_instruction_text, ai.related_instruction_text),
      list_match_score(manual.work_process_titles, ai.work_process_titles),
      work_process_hours_match_score(occupation_standard, manual.ojt_hours, ai.ojt_hours),
      list_match_score(manual.competency_titles, ai.competency_titles),
      list_match_score(manual.related_instruction_titles, ai.related_instruction_titles),
      baseline_success_score(occupation_standard, baseline_candidate, manual, ai),
      json_value(manual.work_process_rows),
      json_value(ai.work_process_rows),
      json_value(list_difference(manual.work_process_titles, ai.work_process_titles)),
      json_value(list_difference(ai.work_process_titles, manual.work_process_titles)),
      json_value(manual.competency_titles),
      json_value(ai.competency_titles),
      json_value(list_difference(manual.competency_titles, ai.competency_titles)),
      json_value(list_difference(ai.competency_titles, manual.competency_titles)),
      json_value(manual.related_instruction_titles),
      json_value(ai.related_instruction_titles),
      json_value(list_difference(manual.related_instruction_titles, ai.related_instruction_titles)),
      json_value(list_difference(ai.related_instruction_titles, manual.related_instruction_titles)),
      mismatch_category(manual.work_process_titles, ai.work_process_titles, baseline_quality_risk: manual.work_process_quality_risk?),
      mismatch_category(manual.competency_titles, ai.competency_titles),
      mismatch_category(manual.related_instruction_titles, ai.related_instruction_titles),
      duplicate_count(manual.work_process_titles),
      manual.work_process_titles.count { |title| title.to_s.match?(/\b\d[\d,.]*\s*hours?\b/i) },
      hierarchy_boundary_overlap_count(manual, ai)
    ]
  end

  def json_value(value)
    JSON.generate(value)
  end

  def list_difference(values, comparison_values)
    remaining = Array(comparison_values).group_by { |value| normalize_text(value) }.transform_values(&:count)

    Array(values).reject do |value|
      normalized = normalize_text(value)
      next false unless remaining[normalized].to_i.positive?

      remaining[normalized] -= 1
      true
    end
  end

  def mismatch_category(expected, actual, baseline_quality_risk: false)
    return "exact" if normalize_list(expected) == normalize_list(actual)
    return "baseline_quality_risk" if baseline_quality_risk
    return "wording_only" if expected.count == actual.count && list_text_similarity(expected, actual) >= 0.8
    return "extraction_omission" if actual.count < expected.count
    return "extraction_overreach" if actual.count > expected.count

    "mixed_mismatch"
  end

  def list_text_similarity(expected, actual)
    expected_tokens = tokenize(Array(expected).join(" "))
    actual_tokens = tokenize(Array(actual).join(" "))
    union = expected_tokens.union(actual_tokens)
    return 1.0 if union.empty?

    expected_tokens.intersection(actual_tokens).count.to_f / union.count
  end

  def duplicate_count(values)
    normalized = Array(values).map { |value| normalize_text(value) }
    normalized.count - normalized.uniq.count
  end

  def hierarchy_boundary_overlap_count(manual, ai)
    manual_work_processes = normalize_list(manual.work_process_titles)
    manual_competencies = normalize_list(manual.competency_titles)
    ai_work_processes = normalize_list(ai.work_process_titles)
    ai_competencies = normalize_list(ai.competency_titles)

    manual_work_processes.intersection(ai_competencies).count +
      ai_work_processes.intersection(manual_competencies).count
  end

  def boolean_value(value)
    value ? 1 : 0
  end

  def baseline_candidate?(occupation_standard, manual)
    occupation_standard.registration_agency&.oa? &&
      occupation_standard.state.present? &&
      manual.source_pdf_occupation_standard_count == 1
  end

  def open_ai_import_for(occupation_standard)
    occupation_standard.open_ai_import ||
      occupation_standard.source_imports.filter_map(&:open_ai_import).max_by(&:created_at)
  end

  def baseline_success_score(occupation_standard, baseline_candidate, manual, ai)
    return unless baseline_candidate

    scores = [
      list_match_score(manual.work_process_titles, ai.work_process_titles),
      work_process_hours_match_score(occupation_standard, manual.ojt_hours, ai.ojt_hours),
      list_match_score(manual.competency_titles, ai.competency_titles),
      list_match_score(manual.related_instruction_titles, ai.related_instruction_titles)
    ]

    if scores.all?(100.0)
      100.0
    else
      0.0
    end
  end

  def work_process_hours_match_score(occupation_standard, expected, actual)
    return 100.0 if occupation_standard.competency_based?

    if expected.to_i == actual.to_i
      100.0
    else
      0.0
    end
  end

  def numeric_score(expected, actual)
    expected = expected.to_i
    actual = actual.to_i

    return 100.0 if expected.zero? && actual.zero?
    return 0.0 if expected.zero? || actual.zero?

    (([expected, actual].min.to_f / [expected, actual].max) * 100).round(2)
  end

  def text_score(expected, actual)
    expected_tokens = tokenize(expected)
    actual_tokens = tokenize(actual)

    return 100.0 if expected_tokens.empty? && actual_tokens.empty?
    return 0.0 if expected_tokens.empty? || actual_tokens.empty?

    ((expected_tokens.intersection(actual_tokens).count.to_f / expected_tokens.count) * 100).round(2)
  end

  def tokenize(text)
    text.to_s.downcase.scan(/[a-z0-9]+/).uniq
  end

  def list_match_score(expected, actual)
    if normalize_list(expected) == normalize_list(actual)
      100.0
    else
      0.0
    end
  end

  def normalize_list(values)
    Array(values).map { |value| normalize_text(value) }.compact_blank.sort
  end

  def normalize_text(value)
    value.to_s.downcase.scan(/[a-z0-9]+/).join(" ")
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

    def source_pdf_occupation_standard_count
      source_pdf_occupation_standard_ids.count
    end

    def work_process_titles
      work_processes.map(&:title)
    end

    def work_process_rows
      work_processes.map do |work_process|
        {
          title: work_process.title,
          defaultHours: work_process.default_hours,
          minimumHours: work_process.minimum_hours,
          maximumHours: work_process.maximum_hours
        }.compact
      end
    end

    def work_process_quality_risk?
      normalized_titles = work_process_titles.map { |title| title.to_s.downcase.scan(/[a-z0-9]+/).join(" ") }
      normalized_titles.uniq.count != normalized_titles.count ||
        work_process_titles.any? { |title| title.to_s.match?(/\b\d[\d,.]*\s*hours?\b/i) }
    end

    def competency_titles
      work_processes.flat_map(&:competencies).map(&:title)
    end

    def related_instruction_titles
      related_instructions.map(&:title)
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

    def source_pdf_occupation_standard_ids
      source_pdfs.flat_map do |import|
        import.data_imports.filter_map(&:occupation_standard_id)
      end.uniq
    end

    def source_pdfs
      occupation_standard.data_imports.filter_map(&:import).uniq
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
        integer_value(
          work_process,
          "maximumHours",
          "maximum_hours",
          "maxHours",
          "max_hours",
          "minimumHours",
          "minimum_hours",
          "minHours",
          "min_hours",
          "defaultHours",
          "default_hours",
          "estimatedHours",
          "estimated_hours",
          "hours"
        )
      end
    end

    def related_instruction_count
      related_instructions.count
    end

    def related_instruction_hours
      related_instructions.sum { |instruction| integer_value(instruction, "hours", "defaultHours", "default_hours", "estimatedHours", "estimated_hours") }
    end

    def work_process_text
      work_processes.map { |work_process| text_value(work_process, "title", "name", "workProcess", "work_process", "workActivity", "work_activity", "task", "duty", "description") }.join(" ")
    end

    def work_process_titles
      work_processes.filter_map { |work_process| value(work_process, "title", "name", "workProcess", "work_process", "workActivity", "work_activity", "task", "duty") }
    end

    def work_process_rows
      work_processes.map do |work_process|
        {
          title: value(work_process, "title", "name", "workProcess", "work_process", "workActivity", "work_activity", "task", "duty"),
          defaultHours: value(work_process, "defaultHours", "default_hours", "estimatedHours", "estimated_hours", "hours"),
          minimumHours: value(work_process, "minimumHours", "minimum_hours", "minHours", "min_hours"),
          maximumHours: value(work_process, "maximumHours", "maximum_hours", "maxHours", "max_hours")
        }.compact
      end
    end

    def skill_text
      work_processes.flat_map { |work_process| competencies(work_process) }.map do |competency|
        competency.is_a?(Hash) ? value(competency, "title", "name", "skill", "task", "duty", "description", "text") : competency
      end.join(" ")
    end

    def competency_titles
      work_processes.flat_map { |work_process| competencies(work_process) }.filter_map do |competency|
        competency.is_a?(Hash) ? value(competency, "title", "name", "skill", "task", "duty", "description", "text") : competency
      end
    end

    def related_instruction_text
      related_instructions.map { |instruction| text_value(instruction, "title", "name", "course", "courseTitle", "course_title", "description") }.join(" ")
    end

    def related_instruction_titles
      related_instructions.filter_map { |instruction| value(instruction, "title", "name", "course", "courseTitle", "course_title") }
    end

    def document_occupation_count
      integer_value(response, "documentOccupationCount", "document_occupation_count", "occupationCount", "occupation_count")
    end

    def single_occupation
      value(response, "singleOccupation", "single_occupation")
    end

    def selected_occupation_title
      value(response, "selectedOccupationTitle", "selected_occupation_title")
    end

    private

    attr_reader :response

    def work_processes
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
      ))
    end

    def related_instructions
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
      ))
    end

    def competencies(work_process)
      Array(value(work_process, "competencies", "skills", "tasks", "duties", "performanceObjectives", "performance_objectives"))
    end

    def integer_value(hash, *keys)
      raw_value = value(hash, *keys)
      return 0 if raw_value.blank?

      match = raw_value.to_s.delete(",").match(/\d+/)
      match ? match[0].to_i : 0
    end

    def value(hash, *keys)
      return unless hash.respond_to?(:[])

      keys.lazy.map { |key| hash[key] || hash[key.to_sym] }.find(&:present?)
    end

    def text_value(hash, *keys)
      return "" unless hash.respond_to?(:[])

      keys.filter_map { |key| (hash[key] || hash[key.to_sym]).presence }.join(" ")
    end
  end
end
