module Admin
  class ImportsController < Admin::ApplicationController
    # Override this method to specify custom lookup behavior.
    # This will be used to set the resource for the `show`, `edit`, and `update`
    # actions.
    #
    # def find_resource(param)
    #   Foo.find_by!(slug: param)
    # end

    # The result of this lookup will be available as `requested_resource`

    # Override this if you have certain roles that require a subset
    # this will be used to set the records shown on the `index` action.
    #
    def scoped_resource
      scope = if current_user.converter? || params[:pdf_only] == "true"
        Imports::Pdf
      else
        resource_class
      end
      scope.preload(file_attachment: :blob)
    end

    private

    def resource_params
      super.permit(policy(requested_resource).permitted_attributes)
    end

    def after_resource_updated_path(resource)
      params[:redirect_back_to].presence || admin_imports_path
    end
  end
end
