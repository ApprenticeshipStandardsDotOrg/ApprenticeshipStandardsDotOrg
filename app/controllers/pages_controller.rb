class PagesController < ApplicationController
  def home
    @popular_onet_codes = PopularOnetCodesQuery.run
  end

  def about
  end
end
