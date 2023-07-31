class IndustriesController < ApplicationController
  def index
    industry_info = Industry.current.order(:name).pluck(:name, :id, :prefix).sort
    @names_by_letter = industry_info.group_by { |industry| industry[0][0] }
    @page_title = "Industries"
  end
end
