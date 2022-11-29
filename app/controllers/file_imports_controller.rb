class FileImportsController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  include ActiveStorage::SetCurrent

  def index
    @file_imports = FileImport.includes(active_storage_attachment: :blob)
  end
end
