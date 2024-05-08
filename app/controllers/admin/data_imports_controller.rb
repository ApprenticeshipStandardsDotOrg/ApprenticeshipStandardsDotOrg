module Admin
  class DataImportsController < Admin::ApplicationController
    before_action :set_parent, except: [:show]

    def new
      if Flipper.enabled?(:show_imports_in_administrate)
        resource = new_resource
        resource.import = @import
        authorize_resource(resource)
        render locals: {
          page: Administrate::Page::Form.new(dashboard, resource)
        }
      else
        resource = new_resource
        resource.source_file = @source_file
        authorize_resource(resource)
        render locals: {
          page: Administrate::Page::Form.new(dashboard, resource)
        }
      end
    end

    def create
      if Flipper.enabled?(:show_imports_in_administrate)
        data_import = @import.data_imports.build(resource_params)
        data_import.user = current_user
        authorize_resource(data_import)

        if data_import.save!
          ProcessDataImportJob.perform_later(data_import: data_import, last_file: last_file_flag)

          redirect_to(
            after_data_import_created_path(@import, data_import),
          )
        else
          render :new, locals: {
            page: Administrate::Page::Form.new(dashboard, data_import)
          }, status: :unprocessable_entity
        end
      else
        data_import = @source_file.data_imports.build(resource_params)
        data_import.user = current_user
        authorize_resource(data_import)

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
      authorize(requested_resource)
      if requested_resource.destroy
        occupation_standard = requested_resource.occupation_standard
        if occupation_standard && occupation_standard.data_imports.empty?
          occupation_standard.destroy!
        end
        flash[:notice] = translate_with_resource("destroy.success")
      else
        flash[:error] = requested_resource.errors.full_messages.join("<br/>")
      end
      if Flipper.enabled?(:show_imports_in_administrate)
        redirect_to after_resource_destroyed_path(@import)
      else
        redirect_to after_resource_destroyed_path(@source_file)
      end
    end

    private

    def set_parent
      if Flipper.enabled?(:show_imports_in_administrate)
        @import = Imports::Pdf.find(params[:import_id])
      else
        @source_file = SourceFile.find(params[:source_file_id])
      end
    end

    def last_file_flag
      params[:last_file] == "1"
    end

    def after_data_import_created_path(parent, data_import)
      if Flipper.enabled?(:show_imports_in_administrate)
        admin_import_data_import_path(parent, data_import)
      else
        admin_source_file_data_import_path(parent, data_import)
      end
    end

    def after_resource_updated_path(source_file, data_import)
      admin_source_file_data_import_path(source_file, data_import)
    end

    def after_resource_destroyed_path(parent)
      if Flipper.enabled?(:show_imports_in_administrate)
        admin_import_path(parent)
      else
        admin_source_file_path(parent)
      end
    end
  end
end
