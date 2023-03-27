class OccupationStandardsController < ApplicationController
  def index
    @occupation_standards = OccupationStandard.all
  end

  def show
    # @occupation_standard = OccupationStandard.find(params[:id])
  end
end
