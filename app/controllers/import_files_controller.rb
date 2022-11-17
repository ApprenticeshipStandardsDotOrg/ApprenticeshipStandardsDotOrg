class ImportFilesController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
  end
end
