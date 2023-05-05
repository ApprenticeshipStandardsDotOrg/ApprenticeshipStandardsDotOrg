class OccupationStandardQuery
  ATTRIBUTES = %i[
    search_term_params
  ]

  # Container is a wrapper for the params involved in the search

  Container = Struct.new(*ATTRIBUTES, keyword_init: true)

  def self.run(occupation_standards, search_term_params)
    return occupation_standards if search_term_params.blank?

    occupation_standards
      .by_state_id(search_term_params[:state_id])
      .by_national_standard_type(search_term_params[:national_standard_type]&.keys)
      .by_ojt_type(search_term_params[:ojt_type]&.keys)
      .and(
        occupation_standards.by_title(search_term_params[:q])
        .or(
          occupation_standards.by_rapids_code(search_term_params[:q])
        )
        .or(
          occupation_standards.by_onet_code(search_term_params[:q])
        )
      )
  end
end
