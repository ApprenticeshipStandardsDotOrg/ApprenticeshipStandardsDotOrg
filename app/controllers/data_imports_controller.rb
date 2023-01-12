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
    @data_import = DataImport.includes(file_attachment: :blob).find(params[:id])
  end

  private

  def create_params
    params.require(:data_import).permit(:description, :file)
  end
end