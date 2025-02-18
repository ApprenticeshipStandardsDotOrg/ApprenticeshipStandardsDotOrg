module Admin
  class OccupationStandardsController < Admin::ApplicationController
    before_action :find_open_ai_import, only: :new

    def new
      if @open_ai_import.present?
        occupation_standard_response = JSON.parse(@open_ai_import.response)
        occupation_standard = OccupationStandard.from_json(occupation_standard_response)

        occupation_standard.open_ai_response = @open_ai_import.response
        occupation_standard.import_id = params[:import_id]
        authorize_resource(occupation_standard)
        render locals: {
          page: Administrate::Page::Form.new(dashboard, occupation_standard)
        }
      else
        skip_authorization
        redirect_to admin_import_path(params[:import_id]), notice: "You must prepare the document by clicking Convert with AI"
      end
    end

    def create
      occupation_standard = new_resource(resource_params)
      authorize_resource(occupation_standard)

      occupation_standard.build_open_ai_import(open_ai_import_params)

      if occupation_standard.save
        occupation_standard.published!
        occupation_standard.open_ai_import.import.archived!
        yield(occupation_standard) if block_given?
        redirect_to(
          after_resource_created_path(occupation_standard),
          notice: translate_with_resource("create.success")
        )
      else
        render :new, locals: {
          page: Administrate::Page::Form.new(dashboard, occupation_standard)
        }, status: :unprocessable_entity
      end
    end

    def scoped_resource
      OccupationStandard.includes(:open_ai_import, occupation: :onet, registration_agency: :state)
    end

    def filter_resources(resources, search_term:)
      Administrate::OccupationStandardSearch.new(
        resources,
        dashboard,
        search_term
      ).run
    end

    private

    def open_ai_import_params
      {
        import_id: params[:occupation_standard][:import_id],
        response: params[:occupation_standard][:open_ai_response]
      }
    end

    def find_open_ai_import
      @open_ai_import = OpenAIImport.find_by(
        import_id: params[:import_id]
      )
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
