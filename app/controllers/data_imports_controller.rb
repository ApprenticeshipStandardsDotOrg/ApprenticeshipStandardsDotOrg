class DataImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_source_file

  def new
    @data_import = @source_file.build_data_import
  end

  def create
    @data_import = @source_file.build_data_import(permitted_params)
    @data_import.user = current_user

    if @data_import.save
      ProcessDataImportJob.perform_later(@data_import)
      flash[:notice] = "Thank you for submitting your occupation standard!"
      redirect_to source_file_data_import_path(@source_file, @data_import)
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
      ProcessDataImportJob.perform_later(@data_import)
      redirect_to source_file_data_import_path(@source_file, @data_import)
    else
      render :edit
    end
  end

  def destroy
    @data_import = DataImport.find(params[:id])

    unless @data_import.destroy
      flash[:error] = "Occupation Standard could not be deleted"
    end
    redirect_to new_source_file_data_import_path(@source_file)
  end

  private

  def set_source_file
    @source_file = SourceFile.find(params[:source_file_id])
  end

  def permitted_params
    params.require(:data_import).permit(:description, :file)
  end
end
