class SourceFilesController < ApplicationController
  before_action :authenticate_user!

  def index
    @source_files = SourceFile.includes(:data_imports, active_storage_attachment: :blob)
  end

  def show
    @source_file = SourceFile.find(params[:id])
  end

  def edit
    @source_file = SourceFile.find(params[:id])
  end

  def update
    @source_file = SourceFile.find(params[:id])
    if @source_file.update(source_file_params)
      redirect_to source_files_path
    else
      render :edit
    end
  end

  def source_file_params
    params.require(:source_file).permit(:status)
  end
end
