module Admin
  class SourceFilesController < Admin::ApplicationController
    def scoped_resource
      SourceFile.includes(:data_imports, active_storage_attachment: :blob).order(created_at: :desc)
    end

    def after_resource_updated_path(resource)
      admin_source_files_path
    end
  end
end
