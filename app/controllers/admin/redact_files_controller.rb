module Admin
  class RedactFilesController < Admin::ApplicationController
    def new
      @record = Imports::Pdf.find(params[:import_id])
      authorize :redact_file, :new?

      # Use a custom layout
      render layout: "admin/pdf_editor"
    end

    def create
      respond_to do |format|
        format.json do
          @record = Import.find(params[:import_id])
          authorize :redact_file, :new?

          if params[:redacted_file]
            @record.redacted_pdf.attach(params[:redacted_file])
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
              status: :unprocessable_content
            }.to_json
          end
        end
      end
    end
  end
end
