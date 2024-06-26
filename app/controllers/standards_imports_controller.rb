class StandardsImportsController < ApplicationController
  include Spammable

  def new
    @standards_import = StandardsImport.new
  end

  def create
    @standards_import = StandardsImport.new(standards_import_params)

    build_uncategorized_imports

    unless user_signed_in?
      @standards_import.courtesy_notification = :pending
    end

    if @standards_import.save
      if user_signed_in?
        redirect_to admin_source_files_path
      else
        @standards_import.notify_admin
        redirect_to standards_import_path(@standards_import)
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    # standard:disable Style/ConditionalAssignment
    if Flipper.enabled?(:show_imports_in_administrate)
      @standards_import = StandardsImport.includes(imports: {file_attachment: :blob}).find(params[:id])
    else
      @standards_import = StandardsImport.includes(files_attachments: [:blob, source_file: :original_source_file]).find(params[:id])
    end
    # standard:enable Style/ConditionalAssignment
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

  def build_uncategorized_imports
    if Flipper.enabled?(:show_imports_in_administrate)
      @standards_import.files.each do |file|
        @standards_import.imports.build(
          type: "Imports::Uncategorized",
          status: :unfurled,
          public_document: @standards_import.public_document,
          file: file.blob
        )
      end
    end
  end
end
