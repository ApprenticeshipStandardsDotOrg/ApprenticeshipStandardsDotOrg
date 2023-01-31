class API::V1::OccupationResource < JSONAPI::Resource
  immutable
  model_name "Occupation"

  attributes :name, :description, :onet_code, :rapids_code, :time_based_hours, :competency_based_hours

  def onet_code
    @model.onet_soc_code
  end

  class << self
    def default_sort
      [{field: "name", direction: :asc}]
    end

    def records_for_populate(options = {})
      super(options).includes(:onet_code)
    end
  end
end
