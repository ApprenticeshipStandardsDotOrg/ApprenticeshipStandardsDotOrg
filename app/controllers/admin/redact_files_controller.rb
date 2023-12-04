module Admin
  class RedactFilesController < Admin::ApplicationController
    def new
      @source_file = SourceFile.find(params[:source_file_id])
      authorize :redact_file, :new?
      # Use a custom layout
      render layout: "admin/pdf_editor"
    end

    def create
      respond_to do |format|
        format.json do
          @source_file = SourceFile.find(params[:source_file_id])
          authorize :redact_file, :new?
          if params[:redacted_file]
            @source_file.redacted_source_file.attach(params[:redacted_file])
            @source_file.associated_occupation_standards.each do |occupation_standard|
              occupation_standard.redacted_document.attach(params[:redacted_file])
            end
            render json: {
              message: "Redacted document saved for all occupation standards associated to this source file",
              status: :ok
            }.to_json
          else
            render json: {
              error: "Redacted document saved for all occupation standards assoaciated to this source file",
              status: :unprocessable_entity
            }.to_json
          end
        end
      end
    end
  end
end
