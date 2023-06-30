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
      .by_state_abbreviation(search_term_params[:state_abbreviation])
      .by_national_standard_type(search_term_params[:national_standard_type]&.keys)
      .by_ojt_type(search_term_params[:ojt_type]&.keys)
      .where(
        "title ILIKE :q OR rapids_code ILIKE :q OR onet_code ILIKE :q OR
        occupation_standards.id IN (
          SELECT occupation_standards.id FROM occupation_standards
          JOIN industries ON occupation_standards.industry_id = industries.id
          WHERE industries.name ILIKE :q
        )",
        q: "%#{search_term_params[:q]}%"
      )
  end
end
