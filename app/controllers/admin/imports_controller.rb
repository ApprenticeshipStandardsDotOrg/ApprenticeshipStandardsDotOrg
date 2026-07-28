module Admin
  class ImportsController < Admin::ApplicationController
    def scoped_resource
      scope = if current_user.converter? || params[:pdf_only] == "true"
        Imports::Pdf
      else
        resource_class
      end
      scope.preload(
        :open_ai_import,
        :data_imports,
        file_attachment: :blob,
        parent: {
          parent: {
            parent: {
              parent: :parent
            }
          }
        }
      )
    end

    def destroy_redacted_pdf
      redacted_pdf = requested_resource.redacted_pdf
      redacted_pdf.purge

      redirect_to admin_import_path(requested_resource)
    end

    def convert_with_ai
      authorize requested_resource

      if requested_resource.open_ai_import&.occupation_standard.present?
        redirect_to(
          admin_import_path(requested_resource),
          alert: existing_open_ai_import_message(requested_resource.open_ai_import)
        )
        return
      end

      PdfReaderJob.perform_later(
        import_id: params[:id],
        open_ai_prompt: OpenAIPrompt.default,
        force: requested_resource.open_ai_import.present?
      )

      redirect_to admin_imports_path, notice: "Started AI conversion."
    end

    private

    def existing_open_ai_import_message(open_ai_import)
      errors = open_ai_import.extraction_errors.presence
      if errors
        "AI conversion already ran but did not create a standard: #{errors.join(", ")}"
      else
        "AI conversion already ran for this import."
      end
    end

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
