module Admin
  class DataImportsController < Admin::ApplicationController
    before_action :set_source_file

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
          page: Administrate::Page::Form.new(dashboard, data_import),
        }, status: :unprocessable_entity
      end
    end

    def update
      if requested_resource.update(resource_params)
        ProcessDataImportJob.perform_later(data_import: requested_resource, last_file: last_file_flag)
        redirect_to(
          after_resource_updated_path(@source_file, requested_resource),
          notice: translate_with_resource("update.success"),
        )
      else
        render :edit, locals: {
          page: Administrate::Page::Form.new(dashboard, requested_resource),
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

    def set_source_file
      @source_file = SourceFile.find(params[:source_file_id])
    end

    # Override this method to specify custom lookup behavior.
    # This will be used to set the data_import for the `show`, `edit`, and `update`
    # actions.
    #
    # def find_data_import(param)
    #   Foo.find_by!(slug: param)
    # end

    # The result of this lookup will be available as `requested_data_import`

    # Override this if you have certain roles that require a subset
    # this will be used to set the records shown on the `index` action.
    #
    # def scoped_data_import
    #   if current_user.super_admin?
    #     data_import_class
    #   else
    #     data_import_class.with_less_stuff
    #   end
    # end

    # Override `data_import_params` if you want to transform the submitted
    # data before it's persisted. For example, the following would turn all
    # empty values into nil values. It uses other APIs such as `data_import_class`
    # and `dashboard`:
    #
    # def data_import_params
    #   params.require(data_import_class.model_name.param_key).
    #     permit(dashboard.permitted_attributes).
    #     transform_values { |value| value == "" ? nil : value }
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
