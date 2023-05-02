class NationalStandardsController < ApplicationController
  def index
  end

  def show
    unless OccupationStandard.respond_to?("national_#{params[:id]}")
      redirect_to national_standards_path
    end
  end
end
