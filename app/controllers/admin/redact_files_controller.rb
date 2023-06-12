module Admin
  class RedactFilesController < Admin::ApplicationController

    def new
      @source_file = SourceFile.find(params[:source_file_id])
      render layout: false
    end
  end
end
