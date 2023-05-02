class NationalStandardsController < ApplicationController
  include Searchable

  def index
    @occupation_standards_search = OccupationStandardQuery::Container.new(search_term_params: search_term_params)

    @occupation_standards = OccupationStandardQuery.run(
      OccupationStandard.where.not(national_standard_type: nil).includes(:organization, occupation: :onet),
      search_term_params
    )

    @pagy, @occupation_standards = pagy(@occupation_standards)
    render "occupation_standards/index"
  end

  def show
    if OccupationStandard.respond_to?("national_#{params[:id]}")
      @occupation_standards_search = OccupationStandardQuery::Container.new(search_term_params: search_term_params)

      @occupation_standards = OccupationStandardQuery.run(
        OccupationStandard.send("national_#{params[:id]}").includes(:organization, occupation: :onet),
        search_term_params
      )

      @pagy, @occupation_standards = pagy(@occupation_standards)
      render "occupation_standards/index"
    else
      redirect_to national_standards_path
    end
  end
end
