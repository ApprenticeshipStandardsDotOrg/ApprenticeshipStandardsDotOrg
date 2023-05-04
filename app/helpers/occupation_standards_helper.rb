module OccupationStandardsHelper
  def ojt_type_display(occupation_standard)
    occupation_standard.ojt_type&.titleize
  end

  def filters_class
    unless params[:state_id].present?
      "hidden"
    end
  end
end
