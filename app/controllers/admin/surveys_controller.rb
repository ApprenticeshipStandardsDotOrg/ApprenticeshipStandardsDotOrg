module Admin
  class SurveysController < Admin::ApplicationController
    def index
      authorize_resource(resource_class)
      search_term = params[:search].to_s.strip
      resources = filter_resources(scoped_resource, search_term: search_term)
      resources = apply_collection_includes(resources)
      resources = order.apply(resources)
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
          @surveys = resources
        end
      end
    end
  end
end

