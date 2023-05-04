module OccupationStandardsHelper
  def ojt_type_display(occupation_standard)
    occupation_standard.ojt_type&.titleize
  end

  def filters_class
    unless params[:state_id].present?
      "hidden"
    end
  end

  def filters_aria_expanded
    (filters_class == "hidden") ? "false" : "true"
  end

  def sponsor_name(occupation_standard)
    if occupation_standard.public_document?
      occupation_standard.organization_title
    else
      "Anonymous"
    end
  end
end
