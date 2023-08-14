module Admin
  class RedactFilesController < Admin::ApplicationController
    def new
      @source_file = SourceFile.find(params[:source_file_id])
      authorize :redact_file, :new?
      # Use a custom layout
      render layout: "admin/pdf_editor"
    end

    def create
      @source_file = SourceFile.find(params[:source_file_id])
      authorize :redact_file, :new?
      if params[:redacted_file]
        @source_file.data_imports.map(&:occupation_standard).each do |occupation_standard|
          occupation_standard.redacted_document.attach(params[:redacted_file])
        end
        flash[:notice] = "Occupation Standards updated with redacted file"
      else
        flash[:alert] = "No changes"
      end

      redirect_to admin_source_file_path(@source_file)
    end
  end
end
