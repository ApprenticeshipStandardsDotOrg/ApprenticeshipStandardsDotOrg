module Admin
  class ImportsController < Admin::ApplicationController
    def scoped_resource
      scope = if current_user.converter? || params[:pdf_only] == "true"
        Imports::Pdf
      else
        resource_class
      end
      scope.preload(:open_ai_import, file_attachment: :blob)
    end

    def destroy_redacted_pdf
      redacted_pdf = requested_resource.redacted_pdf
      redacted_pdf.purge

      redirect_to admin_import_path(requested_resource)
    end

    def convert_with_ai
      authorize requested_resource

      PdfReaderJob.perform_later(params[:id])

      requested_resource.assignee = current_user
      requested_resource.save!

      redirect_to admin_imports_path, notice: "Started AI conversion. You'll be notified when document is ready for review."
    end

    private

    def resource_params
      params.require(requested_resource.class.model_name.param_key)
        .permit(dashboard.permitted_attributes(action_name))
        .transform_values { |v| read_param_value(v) }
        .permit(policy(requested_resource).permitted_attributes)
    end

    def after_resource_updated_path(resource)
      default_path = if current_user.converter?
        admin_imports_path
      else
        admin_import_path(requested_resource)
      end
      params[:redirect_back_to].presence || default_path
    end
  end
end
