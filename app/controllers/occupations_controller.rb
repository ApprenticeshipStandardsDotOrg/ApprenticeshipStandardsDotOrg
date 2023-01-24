class OccupationsController < ApplicationController
  def index
    @occupations = Occupation.all
  end
end
