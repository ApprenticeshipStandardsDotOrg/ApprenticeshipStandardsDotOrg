module Admin
  class RedactFilesController < Admin::ApplicationController
    def new
      @record = if Flipper.enabled?(:show_imports_in_administrate)
        Imports::Pdf.find(params[:import_id])
      else
        SourceFile.find(params[:source_file_id])
      end
      authorize :redact_file, :new?

      # Use a custom layout
      render layout: "admin/pdf_editor"
    end

    def create
      respond_to do |format|
        format.json do
          @record = if Flipper.enabled?(:show_imports_in_administrate)
            Import.find(params[:import_id])
          else
            SourceFile.find(params[:source_file_id])
          end
          authorize :redact_file, :new?

          if params[:redacted_file]
            if Flipper.enabled?(:show_imports_in_administrate)
              @record.redacted_pdf.attach(params[:redacted_file])
            else
              @record.redacted_source_file.attach(params[:redacted_file])
            end
            @record.associated_occupation_standards.each do |occupation_standard|
              occupation_standard.redacted_document.attach(params[:redacted_file])
            end
            @record.update(redacted_at: Time.current)

            render json: {
              message: "Redacted document saved for all occupation standards associated to this source file",
              status: :ok
            }.to_json
          else
            render json: {
              error: "No redacted document was saved",
              status: :unprocessable_entity
            }.to_json
          end
        end
      end
    end
  end
end
