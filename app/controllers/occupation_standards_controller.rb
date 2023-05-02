class OccupationStandardsController < ApplicationController
  include Searchable

  def index
    @occupation_standards_search = OccupationStandardQuery::Container.new(search_term_params: search_term_params)

    @occupation_standards = OccupationStandardQuery.run(
      OccupationStandard.includes(:organization, occupation: :onet),
      search_term_params
    )

    @pagy, @occupation_standards = pagy(@occupation_standards)
  end

  def show
    @occupation_standard = OccupationStandard.find(params[:id])
  end
end
