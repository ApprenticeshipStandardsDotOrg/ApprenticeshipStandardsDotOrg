module Admin
  class SourceFilesController < Admin::ApplicationController
    def scoped_resource
      SourceFile.includes(:data_imports, active_storage_attachment: :blob).order(created_at: :desc)
    end

    def after_resource_updated_path(resource)
      admin_source_files_path
    end

    private

    def accessible_action?(target, action_name)
      debugger
      # super ||
      # target = target.to_sym if target.is_a?(String)
      # target_class_or_class_name =
        # target.is_a?(ActiveRecord::Base) ? target.class : target

      # existing_action?(target_class_or_class_name, action_name) &&
        # authorized_action?(target, action_name)
    end
  end
end
