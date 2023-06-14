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
        .push("LOWER(occupations.title) LIKE ?")
        .join(" OR ")
    end

    def query_values
      values = super
      term = values.first
      values + [term, term]
    end

    def search_results(resources)
      super.left_joins(registration_agency: :state).left_joins(:occupation)
    end
  end
end
