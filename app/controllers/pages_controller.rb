class PagesController < ApplicationController
  def home
    @popular_onet_codes = PopularOnetCodesQuery.run
    @popular_industries = Industry.popular
    @popular_states = State.popular
    @recently_added_occupation_standards = OccupationStandard.recently_added
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

  def fact_sheets
    @page_title = "Fact Sheets"
  end
end
