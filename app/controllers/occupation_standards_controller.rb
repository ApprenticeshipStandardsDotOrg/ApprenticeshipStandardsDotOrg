class OccupationStandardsController < ApplicationController
  def index
    @occupation_standards_search = OccupationStandardQuery::Container.new(q: params[:q])

    @occupation_standards = OccupationStandardQuery.run(
      OccupationStandard.includes(:organization, occupation: :onet),
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
      q: params[:q]
    }
  end
end
