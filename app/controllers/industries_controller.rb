class IndustriesController < ApplicationController
  def index
    @industries = Industry.current.order(:name)
  end
end
