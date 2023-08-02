module Admin
  class RedactFilesController < Admin::ApplicationController
    def new
      @source_file = SourceFile.find(params[:source_file_id])
      authorize :redact_file, :new?
      # Use a custom layout
      render layout: "admin/pdf_editor"
    end
  end
end
