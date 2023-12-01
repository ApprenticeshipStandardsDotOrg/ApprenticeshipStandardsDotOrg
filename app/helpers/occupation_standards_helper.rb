module OccupationStandardsHelper
  def ojt_type_display(occupation_standard)
    occupation_standard.ojt_type&.titleize
  end

  def standard_descendants_accordion_class(record)
    if record.has_details_to_display?
      "accordion"
    end
  end

  def standard_descendants_toggle_icon(record)
    if record.has_details_to_display?
      "before:content-['+']"
    end
  end

  def filters_class
    if params[:state_id].blank? && params[:national_standard_type].blank? && params[:ojt_type].blank?
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
