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
        .push("LOWER(standards_imports.organization) LIKE ?")
        .push("LOWER(users.name) LIKE ?")
        .push("source_files.public_document IN (?)")
        .push("status = ?")
        .join(" OR ")
    end

    def query_values
      values = super
      term = values.first
      values + [term, term, term, db_value_for_public_doc(term), db_value_for_status(term)]
    end

    def search_results(resources)
      super
        .left_joins(active_storage_attachment: :blob)
        .left_joins(:assignee)
        .joins("LEFT JOIN standards_imports ON (active_storage_attachments.record_id = standards_imports.id AND active_storage_attachments.record_type = 'StandardsImport')")
    end

    def db_value_for_status(term)
      SourceFile.statuses[term.parameterize(separator: "_")]
    end

    def db_value_for_public_doc(term)
      (field, value) = term.tr("%", "").split(":")
      (field == "public_document") ? value : nil
    end
  end
end
