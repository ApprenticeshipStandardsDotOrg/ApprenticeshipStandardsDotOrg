class Admin::DataImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_source_file

  def new
    @data_import = @source_file.data_imports.build
  end

  def create
    @data_import = @source_file.data_imports.build(permitted_params)
    @data_import.user = current_user

    if @data_import.save
      ProcessDataImportJob.perform_later(data_import: @data_import, last_file: last_file_flag)
      flash[:notice] = "Thank you for submitting your occupation standard!"
      redirect_to admin_source_file_data_import_path(@source_file, @data_import)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @data_import = DataImport.find(params[:id])
  end

  def edit
    @data_import = DataImport.find(params[:id])
  end

  def update
    @data_import = DataImport.find(params[:id])
    if @data_import.update(permitted_params)
      ProcessDataImportJob.perform_later(data_import: @data_import, last_file: last_file_flag)
      redirect_to admin_source_file_data_import_path(@source_file, @data_import)
    else
      render :edit
    end
  end

  def destroy
    @data_import = DataImport.find(params[:id])

    unless @data_import.destroy
      flash[:error] = "Occupation Standard could not be deleted"
    end
    redirect_to new_admin_source_file_data_import_path(@source_file)
  end

  private

  def set_source_file
    @source_file = SourceFile.find(params[:source_file_id])
  end

  def permitted_params
    params.require(:data_import).permit(:description, :file)
  end

  def last_file_flag
    params[:last_file] == "1"
  end
end
