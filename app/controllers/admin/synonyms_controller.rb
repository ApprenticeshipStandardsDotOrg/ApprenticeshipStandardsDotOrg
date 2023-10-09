module Admin
  class SynonymsController < Admin::ApplicationController
    def create
      resource = new_resource(resource_params)
      authorize_resource(resource)

      if resource.save
        resource.add_to_elastic_search_synonyms
        redirect_to(
          after_resource_created_path(resource),
          notice: translate_with_resource("create.success")
        )
      else
        render :new, locals: {
          page: Administrate::Page::Form.new(dashboard, resource)
        }, status: :unprocessable_entity
      end
    end

    def update
      if requested_resource.update(resource_params)
        requested_resource.add_to_elastic_search_synonyms
        redirect_to(
          after_resource_updated_path(requested_resource),
          notice: translate_with_resource("update.success")
        )
      else
        render :edit, locals: {
          page: Administrate::Page::Form.new(dashboard, requested_resource)
        }, status: :unprocessable_entity
      end
    end

    def destroy
      if requested_resource.destroy
        requested_resource.remove_from_elastic_search_synonyms
        flash[:notice] = translate_with_resource("destroy.success")
      else
        flash[:error] = requested_resource.errors.full_messages.join("<br/>")
      end
      redirect_to after_resource_destroyed_path(requested_resource)
    end
  end
end
