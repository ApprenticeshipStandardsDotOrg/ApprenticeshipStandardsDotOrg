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

  private

  def admin_filter_search_words
    params[:search].to_s.split
  end
end
