class PagesController < ApplicationController
  def home
    @popular_onet_codes = PopularOnetCodesQuery.run
    @popular_industries = Industry.popular
  end

  def about
    @page_title = "About"
  end

  def definitions
    @page_title = "Definitions"
  end

  def terms
    @page_title = "Privacy/Terms"
  end
end
