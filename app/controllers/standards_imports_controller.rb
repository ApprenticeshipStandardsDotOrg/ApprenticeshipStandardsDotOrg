class StandardsImportsController < ApplicationController
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
  end

  private

  def create_params
    params.require(:standards_import).permit(:name, :email, :organization, :notes)
  end
end
