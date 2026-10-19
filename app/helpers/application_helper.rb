module ApplicationHelper
  include Pagy::Frontend

  def search_form_url
    target = (controller_name == "pages") ? "occupation_standards" : controller_name
    url_for(controller: target, action: "index")
  end

  def national_standard_types_filter
    @_filter ||= OccupationStandard.national_standard_types.transform_values { 1 }
  end

  def occupation_standards_page_active?
    current_page?(occupation_standards_path) && !national_page_active?
  end

  def national_page_active?
    current_page?(occupation_standards_path(national_standard_type: national_standard_types_filter), check_parameters: true)
  end

  def admin_filter_search_terms_without(*prefixes)
    admin_filter_search_words.reject do |word|
      prefixes.flatten.any? { |prefix| word.start_with?("#{prefix}:") }
    end
  end

  def admin_filter_value(prefix)
    admin_filter_search_words.find { |word| word.start_with?("#{prefix}:") }&.split(":", 2)&.last
  end

  def admin_filter_search(search_terms, filters)
    filter_terms = filters.filter_map do |prefix, value|
      if value == true
        "#{prefix}:"
      else
        values = Array(value).compact_blank
        "#{prefix}:#{values.join(",")}" if values.any?
      end
    end

    (search_terms + filter_terms).join(" ")
  end

  def admin_filter_url(search, extra_params = {})
    query = request.query_parameters.except("_page").merge("search" => search).merge(extra_params)
    query.delete("search") if search.blank?
    query.delete("pdf_only") if query["pdf_only"].blank?
    url_for(query)
  end

  def admin_filter_option_class(active)
    base = "inline-flex items-center rounded-md border px-2.5 py-1.5 text-sm font-medium transition"

    if active
      "#{base} border-blue-700 bg-blue-700 text-white hover:bg-blue-800"
    else
      "#{base} border-gray-300 bg-white text-gray-700 hover:border-blue-500 hover:text-blue-700"
    end
  end

  def sample_csv_report_field_definitions
    {
      id: "Production admin URL for the occupation standard in this row.",
      registration_agency_name: "Registration agency name, for example Texas (OA).",
      source_pdf_occupation_scope: "single or multiple based on distinct standards linked through source PDF Data Imports, excluding the AI comparison copy; unknown without linked standards. Inferred from links, not verified PDF contents.",
      baseline_title: "RAPIDS/manual comparison title; blank if no unambiguous baseline is available.",
      title: "0 or 1: title present and fuzzy matching the baseline (at least 80% token overlap).",
      onet_code: "0 or 1: O*NET code present and matching the baseline.",
      rapids_code: "0 or 1: RAPIDS code present and matching the baseline.",
      source_document: "0 or 1: AI conversion uses the same attached source PDF as the baseline.",
      occupation: "0 or 1: occupation present and matching by ID or fuzzy title.",
      ojt_type: "0 or 1: OJT type present and matching the baseline.",
      registration_agency: "0 or 1: registration agency and state match the baseline.",
      work_processes: "0–2: missing, present but differing, or at least 80% token overlap across process and competency text. Counts and grouping need not match. Both absent receives 2 (not applicable).",
      instructions: "0–2: missing, present but differing, or at least 80% token overlap across related instruction text. Counts and grouping need not match. Both absent receives 2 (not applicable).",
      total_points: "Sum of the nine field scores. All scores are 0 when a successful conversion or unambiguous baseline is missing.",
      total_possible: "11 possible points.",
      total_percentage: "Total points / 11 × 100. Automatic baseline comparison, not verified PDF accuracy."
    }
  end

  def full_sample_csv_report_field_definitions
    {
      id: "Occupation standard ID.",
      title: "Occupation standard title.",
      state: "Registration agency state abbreviation.",
      state_registered: "Whether the standard is associated with a state registration agency.",
      agency_type: "Registration agency type: oa or saa.",
      ojt_type: "OJT type: time, competency, or hybrid.",
      source: "Occupation standard source classification.",
      organization: "Associated sponsor or organization name.",
      has_org: "Whether an organization is associated.",
      onet_code: "O*NET code stored on the standard.",
      rapids_code: "RAPIDS code stored on the standard.",
      import_user: "Latest associated manual data import user, when available.",
      converted_at: "Latest associated manual data import update time.",
      ai_converted_at: "AI conversion creation time, when available.",
      source_pdf_standard_count: "Number of occupation standards linked to the same source PDF.",
      baseline_oa_state_single_occupation: "1 when the row is an OA state standard linked to a source PDF with one occupation standard; otherwise 0.",
      manual_wp_count: "Persisted work process count.",
      ai_wp_count: "AI extracted work process count.",
      manual_skill_count: "Persisted competency count across work processes.",
      ai_skill_count: "AI extracted competency count.",
      manual_ojt_hours: "Persisted total work process hours.",
      ai_ojt_hours: "AI extracted total work process hours.",
      manual_ri_count: "Persisted related instruction count.",
      ai_ri_count: "AI extracted related instruction count.",
      manual_ri_hours: "Persisted total related instruction hours.",
      ai_ri_hours: "AI extracted total related instruction hours.",
      score_wp_count: "Work process count match score.",
      score_skill_count: "Competency count match score.",
      score_ojt_hours: "OJT hours match score.",
      score_ri_count: "Related instruction count match score.",
      score_ri_hours: "Related instruction hours match score.",
      score_wp_text: "Work process text token-overlap score.",
      score_skill_text: "Competency text token-overlap score.",
      score_ri_text: "Related instruction text token-overlap score.",
      score_wp_names_match: "100 when normalized work process titles match exactly; otherwise 0.",
      score_wp_hours_match: "100 when total work process hours match exactly, or when hours are not applicable for competency-based standards; otherwise 0.",
      score_competency_names_match: "100 when normalized competency titles match exactly; otherwise 0.",
      score_ri_titles_match: "100 when normalized related instruction titles match exactly; otherwise 0.",
      score_oa_single_occupation_success: "100 when the OA state single-occupation baseline row matches all measured extraction fields; otherwise 0. Blank for rows outside the baseline cohort."
    }
  end

  private

  def admin_filter_search_words
    params[:search].to_s.split
  end
end
