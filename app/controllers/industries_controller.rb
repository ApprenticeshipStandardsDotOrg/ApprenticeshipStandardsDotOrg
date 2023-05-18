class IndustriesController < ApplicationController
  def index
    @industries = Industry.current.order(:name)
    industry_info = @industries.pluck(:name, :id, :prefix).sort
    @names_by_letter = industry_info.group_by { |industry| industry[0][0] }
  end
end
