module Admin
  class OccupationStandardsController < Admin::ApplicationController
    def scoped_resource
      OccupationStandard.includes(occupation: :onet, registration_agency: :state)
    end

    def filter_resources(resources, search_term:)
      Administrate::OccupationStandardSearch.new(
        resources,
        dashboard,
        search_term
      ).run
    end
  end
end

module Administrate
  class OccupationStandardSearch < Search
    private

    def query_template
      super
        .split(" OR ")
        .push("LOWER(states.name) LIKE ?")
        .join(" OR ")
    end

    def query_values
      values = super
      term = values.first
      values + [term]
    end

    def search_results(resources)
      super.joins(registration_agency: :state)
    end
  end
end
