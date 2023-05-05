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
    params.permit(
      :q,
      :state_id,
      ojt_type: [:time, :hybrid, :competency],
      national_standard_type: [
        :program_standard, :guideline_standard, :occupational_framework
      ]
    )
  end

  def standards_scope
    OccupationStandard.includes(:organization, registration_agency: :state, occupation: :onet)
  end
end
