class OccupationStandardsController < ApplicationController
  def index
    @occupation_standards_search = OccupationStandardQuery::Container.new(search_term_params: search_term_params)

    @occupation_standards = OccupationStandardQuery.run(
      standards_scope,
      search_term_params
    )

    @pagy, @occupation_standards = pagy(@occupation_standards)
  end

  def show
    @occupation_standard = OccupationStandard.find(params[:id])
  end

  private

  def search_term_params
    {
      q: params[:q],
      state_id: params[:state_id]
    }
  end

  def standards_scope
    OccupationStandard.includes(:organization, occupation: :onet)
  end
end
