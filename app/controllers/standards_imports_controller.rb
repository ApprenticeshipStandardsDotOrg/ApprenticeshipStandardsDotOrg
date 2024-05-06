class StandardsImportsController < ApplicationController
  include Spammable

  def new
    @standards_import = StandardsImport.new
  end

  def create
    @standards_import = StandardsImport.new(standards_import_params)

    unless user_signed_in?
      @standards_import.courtesy_notification = :pending
      @standards_import.imports.each do |import|
        import.courtesy_notification = :pending
      end
    end

    if @standards_import.save
      if user_signed_in?
        redirect_to admin_source_files_path
      else
        @standards_import.notify_admin
        redirect_to standards_import_path(@standards_import)
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @standards_import = StandardsImport.includes(files_attachments: [:blob, source_file: :original_source_file]).find(params[:id])
  end

  private

  def standards_import_params
    if current_user&.admin?
      admin_create_params
    else
      user_create_params
    end
  end

  def user_create_params
    params.require(:standards_import).permit(:name, :email, :organization, :notes, files: [])
  end

  def admin_create_params
    params.require(:standards_import).permit(
      :name,
      :email,
      :organization,
      :notes,
      :public_document,
      files: []
    )
  end
end
