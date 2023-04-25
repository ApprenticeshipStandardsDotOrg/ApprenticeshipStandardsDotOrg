class OccupationStandardsController < ApplicationController
  def index
    @occupation_standards = OccupationStandard.includes(:organization, occupation: :onet)
  end

  def show
    #@occupation_standard = OccupationStandard.find(params[:id])
  end
end
