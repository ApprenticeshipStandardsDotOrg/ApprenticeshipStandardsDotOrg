module Admin
  class SourceFilesController < Admin::ApplicationController
    def scoped_resource
      SourceFile.includes(:assignee, :data_imports, active_storage_attachment: [:blob, :record]).order(created_at: :desc)
    end

    def after_resource_updated_path(resource)
      params[:redirect_back_to].presence || admin_source_files_path
    end

    def filter_resources(resources, search_term:)
      Administrate::SourceFileSearch.new(
        resources,
        dashboard,
        search_term
      ).run
    end

    private

    def resource_params
      super.permit(policy(requested_resource).permitted_attributes)
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
        .push("status = ?")
        .join(" OR ")
    end

    def query_values
      values = super
      term = values.first
      values + [term, db_value_for_status(term)]
    end

    def search_results(resources)
      super.left_joins(active_storage_attachment: :blob)
    end

    def db_value_for_status(term)
      SourceFile.statuses[term.parameterize(separator: "_")]
    end
  end
end
