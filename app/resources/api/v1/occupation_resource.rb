class API::V1::OccupationResource < JSONAPI::Resource
  immutable
  model_name "Occupation"

  attributes :title, :onet_code, :rapids_code, :time_based_hours, :competency_based_hours

  class << self
    def default_sort
      [{field: "title", direction: :asc}]
    end

    def records_for_populate(options = {})
      super.includes(:onet)
    end
  end
end
