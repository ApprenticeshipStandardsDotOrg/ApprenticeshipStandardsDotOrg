class DataImportsController < ApplicationController
  before_action :authenticate_user!

  def new
    @data_import = DataImport.new
  end

  def create
    @data_import = DataImport.new(create_params)
    @data_import.user = current_user

    if @data_import.save
      redirect_to data_import_path(@data_import)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @data_import = DataImport.find(params[:id])
  end

  def destroy
    @data_import = DataImport.find(params[:id])
    
    unless @data_import.destroy
      flash[:error] = "Occupation Standard could not be deleted"
    end
    redirect_to new_data_import_path
  end

  private

  def create_params
    params.require(:data_import).permit(:description, :file)
  end
end