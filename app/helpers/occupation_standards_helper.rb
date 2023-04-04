module OccupationStandardsHelper
  def ojt_type_display(occupation_standard)
    occupation_standard.ojt_type&.titleize
  end
end
