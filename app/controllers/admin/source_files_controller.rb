module Admin
  class SourceFilesController < Admin::ApplicationController
    def scoped_resource
      SourceFile.includes(:data_imports, active_storage_attachment: :blob).order(created_at: :desc)
    end
  end
end
