module Admin
  class SourceFilesController < Admin::ApplicationController
    skip_after_action :verify_authorized, only: :index

    def index
      redirect_to admin_imports_url
    end

    def scoped_resource
      if params[:filter_by] == "needs_redaction"
        SourceFile.preload(active_storage_attachment: [:record]).ready_for_redaction
      elsif params[:filter_by] == "redacted"
        SourceFile.preload(active_storage_attachment: [:record, :blob]).already_redacted
      else
        SourceFile.includes(:assignee, :data_imports, active_storage_attachment: [:blob, :record]).order(created_at: :desc)
      end
    end

    def after_resource_updated_path(resource)
      params[:redirect_back_to].presence || admin_source_files_path
    end

    def filter_resources(resources, search_term:)
      resources =
        if Administrate::SourceFileSearch.user_is_filtering_by_status?(search_term)
          resources
        else
          resources.not_archived
        end

      Administrate::SourceFileSearch.new(
        resources,
        dashboard,
        search_term
      ).run
    end

    def destroy_redacted_source_file
      redacted_source_file = requested_resource.redacted_source_file
      redacted_source_file.purge
      redirect_to admin_source_file_path(requested_resource)
    end

    private

    def resource_params
      super.permit(policy(requested_resource).permitted_attributes)
    end
  end
end

module Administrate
  class SourceFileSearch < Search
    def self.user_is_filtering_by_status?(term)
      db_value_for_status(term).present?
    end

    def self.db_value_for_status(term)
      SourceFile.statuses[term.parameterize(separator: "_")]
    end

    private

    def query_template
      super
        .split(" OR ")
        .push("LOWER(active_storage_blobs.filename) LIKE ?")
        .push("LOWER(standards_imports.organization) LIKE ?")
        .push("LOWER(users.name) LIKE ?")
        .push("source_files.public_document = ?")
        .join(" OR ")
        .then { add_status_query(_1) }
    end

    def query_values
      values = super
      term = values.first
      values +=
        [
          term, # filename
          term, # organization
          term, # user name
          db_value_for_public_doc(term) # public doc
        ]

      if self.class.user_is_filtering_by_status?(term)
        values + [self.class.db_value_for_status(term)]
      else
        values
      end
    end

    def search_results(resources)
      super
        .left_joins(active_storage_attachment: :blob)
        .left_joins(:assignee)
        .joins("LEFT JOIN standards_imports ON (active_storage_attachments.record_id = standards_imports.id AND active_storage_attachments.record_type = 'StandardsImport')")
    end

    def add_status_query(query)
      if self.class.user_is_filtering_by_status?(term)
        "#{query} OR status = ?"
      else
        query
      end
    end

    def db_value_for_public_doc(term)
      (field, value) = term.tr("%", "").split(":")
      (field == "public_document") ? value : nil
    end
  end
end
