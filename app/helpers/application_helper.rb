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
    !current_page?(occupation_standards_path(national_standard_type: national_standard_types_filter), check_parameters: true) &&
      current_page?(occupation_standards_path)
  end

  def national_page_active?
    current_page?(occupation_standards_path(national_standard_type: national_standard_types_filter), check_parameters: true)
  end
end
