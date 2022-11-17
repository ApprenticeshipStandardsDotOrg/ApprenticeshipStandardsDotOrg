class StandardsImportsController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
  end

  def new
    @standards_import = StandardsImport.new
  end

  def create
    @standards_import = StandardsImport.new(create_params)

    if @standards_import.save
      redirect_to standards_import_path(@standards_import)
    else
      render :new
    end
  end

  def show
    @standards_import = StandardsImport.includes(files_attachments: :blob).find(params[:id])
  end

  private

  def create_params
    params.require(:standards_import).permit(:name, :email, :organization, :notes, files: [])
  end
end
