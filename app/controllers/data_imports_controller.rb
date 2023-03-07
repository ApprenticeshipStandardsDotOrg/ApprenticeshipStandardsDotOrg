class DataImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_file_import

  def new
    @data_import = @file_import.build_data_import
  end

  def create
    @data_import = @file_import.build_data_import(permitted_params)
    @data_import.user = current_user

    if @data_import.save
      ProcessDataImportJob.perform_later(@data_import)
      flash[:notice] = "Thank you for submitting your occupation standard!"
      redirect_to file_import_data_import_path(@file_import, @data_import)
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
      redirect_to file_import_data_import_path(@file_import, @data_import)
    else
      render :edit
    end
  end

  def destroy
    @data_import = DataImport.find(params[:id])

    unless @data_import.destroy
      flash[:error] = "Occupation Standard could not be deleted"
    end
    redirect_to new_file_import_data_import_path(@file_import)
  end

  private

  def set_file_import
    @file_import = FileImport.find(params[:file_import_id])
  end

  def permitted_params
    params.require(:data_import).permit(:description, :file)
  end
end
