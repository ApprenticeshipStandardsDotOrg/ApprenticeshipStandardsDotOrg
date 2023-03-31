module Admin
  class DataImportsController < Admin::ApplicationController
    before_action :set_source_file

    def new
      resource = new_resource
      resource.source_file = @source_file
      authorize_resource(resource)
      render locals: {
        page: Administrate::Page::Form.new(dashboard, resource)
      }
    end

    def create
      data_import = @source_file.data_imports.build(resource_params)
      data_import.user = current_user

      if data_import.save
        ProcessDataImportJob.perform_later(data_import: data_import, last_file: last_file_flag)

        redirect_to(
          after_data_import_created_path(@source_file, data_import),
          notice: "Thank you for submitting your occupation standard!"
        )
      else
        render :new, locals: {
          page: Administrate::Page::Form.new(dashboard, data_import)
        }, status: :unprocessable_entity
      end
    end

    def update
      if requested_resource.update(resource_params)
        ProcessDataImportJob.perform_later(data_import: requested_resource, last_file: last_file_flag)
        redirect_to(
          after_resource_updated_path(@source_file, requested_resource),
          notice: translate_with_resource("update.success")
        )
      else
        render :edit, locals: {
          page: Administrate::Page::Form.new(dashboard, requested_resource)
        }, status: :unprocessable_entity
      end
    end

    def destroy
      if requested_resource.destroy
        flash[:notice] = translate_with_resource("destroy.success")
      else
        flash[:error] = requested_resource.errors.full_messages.join("<br/>")
      end
      redirect_to after_resource_destroyed_path(@source_file)
    end

    private

    def set_source_file
      @source_file = SourceFile.find(params[:source_file_id])
    end

    def last_file_flag
      params[:last_file] == "1"
    end

    def after_data_import_created_path(source_file, data_import)
      admin_source_file_data_import_path(source_file, data_import)
    end

    def after_resource_updated_path(source_file, data_import)
      admin_source_file_data_import_path(source_file, data_import)
    end

    def after_resource_destroyed_path(source_file)
      new_admin_source_file_data_import_path(source_file)
    end
  end
end
