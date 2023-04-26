module Admin
  class SourceFilesController < Admin::ApplicationController
    def scoped_resource
      SourceFile.includes(:assignee, :data_imports, active_storage_attachment: [:blob, :record]).order(created_at: :desc)
    end

    def after_resource_updated_path(resource)
      admin_source_files_path
    end

    def filter_resources(resources, search_term:)
      Administrate::SourceFileSearch.new(
        resources,
        dashboard,
        search_term
      ).run
    end
  end
end

module Administrate
  class SourceFileSearch < Search
    private

    def query_template
      super
        .split(" OR ")
        .push("LOWER(active_storage_blobs.filename) LIKE ?")
        .join(" OR ")
    end

    def query_values
      array = super
      array + [array.first]
    end

    def search_results(resources)
      super.left_joins(active_storage_attachment: :blob)
    end
  end
end
