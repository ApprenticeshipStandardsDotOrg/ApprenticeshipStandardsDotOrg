class API::V1::StandardResource < JSONAPI::Resource
  immutable
  model_name "OccupationStandard"

  attributes :title, :existing_title, :sponsor_name, :registration_agency, :onet_code, :rapids_code, :ojt_type, :term_months, :probationary_period_months, :apprenticeship_to_journeyworker_ratio, :ojt_hours_min, :ojt_hours_max, :rsi_hours_min, :rsi_hours_max

  filter :title
  filter :onet_code, apply: ->(records, value, _options) {
    records
      .joins("LEFT JOIN occupations ON (occupations.id = occupation_standards.occupation_id)")
      .joins("LEFT JOIN onets ON (occupations.onet_id = onets.id)")
      .where("onets.code IN (?) OR (onets.id IS NULL AND occupation_standards.onet_code IN (?))", value, value)
  }
  filter :rapids_code, apply: ->(records, value, _options) {
    records
      .joins("LEFT JOIN occupations ON (occupations.id = occupation_standards.occupation_id)")
      .where("occupations.rapids_code IN (?) OR (occupations.rapids_code IS NULL AND occupation_standards.rapids_code IN (?))", value, value)
  }

  def ojt_type
    @model.ojt_type + "_based"
  end

  class << self
    def default_sort
      [{field: "title", direction: :asc}]
    end

    def records_for_populate(options = {})
      super(options).includes(:organization, :registration_agency, occupation: :onet)
    end
  end
end
