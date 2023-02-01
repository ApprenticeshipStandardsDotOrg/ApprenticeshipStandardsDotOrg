class OccupationStandardsController < ApplicationController
  before_action :find_occupation_standard, only: [:show]

  def index
    @occupation_standards = OccupationStandard.all
  end

  def show
  end

  private

  def find_occupation_standard
    @occupation_standard = OccupationStandard.find(params[:id])
  end
end
