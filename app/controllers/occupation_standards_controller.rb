class OccupationStandardsController < ApplicationController
  def index
    @pagy, @occupation_standards = pagy(
      OccupationStandard.includes(:organization, occupation: :onet)
    )
  end

  def show
    @occupation_standard = OccupationStandard.find(params[:id])
  end
end
