module Admin
  class OccupationStandardsController < Admin::ApplicationController
    def new
      open_ai_response = PdfReaderJob.perform_now(params[:import_id])

      occupation_standard_response = JSON.parse(open_ai_response)

      occupation_standard_attributes = OccupationStandard.from_json(occupation_standard_response)

      Rails.logger.info "Attributes from OpenAI: #{occupation_standard_attributes}"
      resource = new_resource(occupation_standard_attributes)
      resource.open_ai_response = open_ai_response
      authorize_resource(resource)
      render locals: {
        page: Administrate::Page::Form.new(dashboard, resource)
      }
    end

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
        .push("occupations.rapids_code LIKE ?")
        .join(" OR ")
    end

    def query_values
      values = super
      term = values.first
      values + [term, term, term]
    end

    def search_results(resources)
      super.left_joins(registration_agency: :state).left_joins(:occupation)
    end
  end
end
