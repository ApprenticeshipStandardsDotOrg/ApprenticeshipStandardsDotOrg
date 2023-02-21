class FileImportsController < ApplicationController
  before_action :authenticate_user!
  include ActiveStorage::SetCurrent

  def index
    @file_imports = FileImport.includes(:data_import, active_storage_attachment: :blob)
  end

  def edit
    @file_import = FileImport.find(params[:id])
  end

  def update
    @file_import = FileImport.find(params[:id])
    if @file_import.update(file_import_params)
      redirect_to file_imports_path
    else
      render :edit
    end
  end

  def file_import_params
    params.require(:file_import).permit(:status)
  end
end
