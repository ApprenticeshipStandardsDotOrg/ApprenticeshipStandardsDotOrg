class OccupationStandardSampleSetScoreReport < OccupationStandardSampleSetReport
  HEADERS = %w[id baseline_title registration_agency_name source_pdf_occupation_scope title onet_code rapids_code source_document occupation ojt_type registration_agency work_processes instructions total_points total_possible total_percentage].freeze
  TOTAL_POSSIBLE = 11
  TEXT_MATCH_THRESHOLD = 0.8

  def initialize(relation, filters:)
    super
    @scope = scope.includes(
      :occupation,
      open_ai_import: {occupation_standard: :occupation, import: [
        :open_ai_import,
        {open_ai_imports: :occupation_standard},
        {file_attachment: :blob},
        {data_imports: {occupation_standard: [:occupation, {data_imports: {import: {file_attachment: :blob}}}, {work_processes: :competencies}, :related_instructions]}}
      ]},
      data_imports: {import: [{file_attachment: :blob}, {open_ai_import: {occupation_standard: [:occupation, :registration_agency]}},
        {open_ai_imports: {occupation_standard: [:occupation, :registration_agency]}}]}
    )
  end

  def to_csv
    CSV.generate do |csv|
      csv << HEADERS
      scope.find_each do |standard|
        csv << score_row(standard)
      end
    end
  end

  private

  def score_row(standard)
    conversion = open_ai_import_for(standard)
    actual = conversion&.occupation_standard
    baseline = if standard.source_ai_conversion?
      candidates = conversion&.import&.data_imports&.filter_map(&:occupation_standard)&.reject(&:source_ai_conversion?)&.uniq || []
      if candidates.length == 1
        candidates.first
      else
        matches = candidates.select { |candidate| conversion.import.ai_import_for(candidate)&.occupation_standard_id == actual&.id }
        matches.first if matches.one?
      end
    else
      standard
    end

    scores = if baseline && actual
      expected_content = ManualSummary.new(baseline)
      actual_content = AISummary.new(conversion.parsed_response)
      [
        fuzzy_match?(baseline.title, actual.title) ? 1 : 0,
        field_score(baseline.onet_code, actual.onet_code),
        field_score(baseline.rapids_code, actual.rapids_code),
        source_score(baseline, conversion),
        occupation_score(baseline.occupation, actual.occupation),
        field_score(baseline.ojt_type, actual.ojt_type),
        field_score(baseline.registration_agency_id, actual.registration_agency_id),
        content_score(expected_content.work_process_text + " " + expected_content.skill_text,
          actual_content.work_process_text + " " + actual_content.skill_text),
        content_score(expected_content.related_instruction_text, actual_content.related_instruction_text)
      ]
    else
      Array.new(9, 0)
    end

    total = scores.sum
    url = Rails.application.routes.url_helpers.admin_occupation_standard_url(standard, host: "admin.apprenticeshipstandards.org", protocol: "https")
    [url, baseline&.title, standard.registration_agency.to_s, standard.source_pdf_occupation_scope,
      *scores, total, TOTAL_POSSIBLE, (total.fdiv(TOTAL_POSSIBLE) * 100).round(2)]
  end

  def field_score(expected, actual)
    (expected.present? && actual.present? && expected.to_s.strip.casecmp?(actual.to_s.strip)) ? 1 : 0
  end

  def occupation_score(expected, actual)
    return 0 unless expected && actual

    (expected.id == actual.id || fuzzy_match?(expected.title, actual.title)) ? 1 : 0
  end

  def source_score(baseline, conversion)
    # Sharing the attached PDF also establishes the same root source URL.
    (baseline.source_imports.any? { |import| import.id == conversion.import_id && import.file.attached? }) ? 1 : 0
  end

  def fuzzy_match?(expected, actual)
    expected.present? && actual.present? && similarity(expected, actual) >= TEXT_MATCH_THRESHOLD
  end

  def content_score(expected, actual)
    expected_tokens = tokenize(expected)
    actual_tokens = tokenize(actual)
    return 2 if expected_tokens.empty? && actual_tokens.empty?
    return 0 if actual_tokens.empty?
    return 1 if expected_tokens.empty?

    (similarity(expected, actual) >= TEXT_MATCH_THRESHOLD) ? 2 : 1
  end

  def similarity(expected, actual)
    expected_tokens = tokenize(expected)
    actual_tokens = tokenize(actual)
    union = expected_tokens.union(actual_tokens)
    return 0.0 if union.empty?

    expected_tokens.intersection(actual_tokens).length.fdiv(union.length)
  end
end
