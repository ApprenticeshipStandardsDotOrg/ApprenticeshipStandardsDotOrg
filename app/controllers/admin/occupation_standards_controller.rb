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

    def index
      authorize_resource(resource_class)
      search_term = params[:search].to_s.strip
      resources = filter_resources(scoped_resource, search_term: search_term)
      resources = apply_collection_includes(resources)
      resources = order.apply(resources)

      # Filter by control_group if specified
      if params[:filter].present? && params[:filter][:control_group].present?
        if params[:filter][:control_group] == "true"
          resources = resources.where(control_group: true)
        elsif params[:filter][:control_group] == "false"
          resources = resources.where(control_group: false)
        end
      end

      resources = paginate_resources(resources)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      respond_to do |format|
        format.html do
          render locals: {
            resources: resources,
            search_term: search_term,
            page: page,
            show_search_bar: show_search_bar?
          }
        end

        format.xlsx do
          # Get all records for export (not paginated)
          export_resources = filter_resources(scoped_resource, search_term: search_term)
          export_resources = apply_collection_includes(export_resources)
          export_resources = order.apply(export_resources)

          # Apply control_group filter if specified
          if params[:filter].present? && params[:filter][:control_group].present?
            if params[:filter][:control_group] == "true"
              export_resources = export_resources.where(control_group: true)
            elsif params[:filter][:control_group] == "false"
              export_resources = export_resources.where(control_group: false)
            end
          end

          @occupation_standards = export_resources.includes(
            :occupation,
            :registration_agency,
            :state,
            :ai_comparison_result,
            registration_agency: :state
          )
          render "index"
        end
      end
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
