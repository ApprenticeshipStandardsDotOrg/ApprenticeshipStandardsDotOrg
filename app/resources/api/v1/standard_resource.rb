class API::V1::StandardResource < JSONAPI::Resource
  immutable
  model_name "OccupationStandard"

  attributes :title, :existing_title, :sponsor_name, :registration_agency, :onet_code, :rapids_code, :ojt_type, :term_months, :probationary_period_months, :apprenticeship_to_journeyworker_ratio, :ojt_hours_min, :ojt_hours_max, :rsi_hours_min, :rsi_hours_max

  filter :title
  filter :onet_code
  filter :rapids_code

  def ojt_type
    if @model.ojt_type
      @model.ojt_type + "_based"
    end
  end

  class << self
    def default_sort
      [{field: "title", direction: :asc}]
    end

    def records_for_populate(options = {})
      super.includes(:organization, :registration_agency, occupation: :onet)
    end
  end
end
