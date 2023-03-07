class API::V1::StandardResource < JSONAPI::Resource
  immutable
  model_name "OccupationStandard"

  attributes :title, :existing_title, :sponsor_name, :registration_agency, :onet_code, :rapids_code, :occupation_type, :term_months, :probationary_period_months, :apprenticeship_to_journeyworker_ratio, :ojt_hours_min, :ojt_hours_max, :rsi_hours_min, :rsi_hours_max

  def occupation_type
    @model.occupation_type + "_based"
  end

  class << self
    def default_sort
      [{field: "title", direction: :asc}]
    end

    def records_for_populate(options = {})
      super(options).includes(:organization, :registration_agency, occupation: :onet_code)
    end
  end
end
