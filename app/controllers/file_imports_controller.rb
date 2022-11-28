class FileImportsController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    @file_imports = FileImport.all
  end
end
