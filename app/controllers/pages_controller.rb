class PagesController < ApplicationController
  def home
    @popular_onet_codes = PopularOnetCodesQuery.run
    @popular_industries = Industry.popular
  end

  def about
  end
end
