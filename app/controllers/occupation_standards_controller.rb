class OccupationStandardsController < ApplicationController
  def index
    @occupation_standards_search = OccupationStandardQuery::Container.new(
      search_term_params: search_term_params
    )

    @occupation_standards = OccupationStandardQuery.run(
      standards_scope,
      search_term_params
    )

    @pagy, @occupation_standards = pagy(@occupation_standards)
    @search_term = search_term_params[:q]

    @page_title = "Occupations"

    respond_to do |format|
      format.json do
        render json: OccupationStandardBlueprint.render(@occupation_standards)
      end
      format.html {}
    end
  end

  def show
    @occupation_standard = OccupationStandard.find(params[:id])
    @page_title = @occupation_standard.title

    respond_to do |format|
      format.html {}
      format.docx do
        export = OccupationStandardExport.new(@occupation_standard)

        send_data(export.call, filename: export.filename)
      end
    end
  end

  private

  def occupation_standards_search_params
    params.permit(
      :q,
      :state_id,
      :state,
      ojt_type: [:time, :hybrid, :competency],
      national_standard_type: [
        :program_standard, :guideline_standard, :occupational_framework
      ]
    )
  end

  def search_term_params
    @search_term_params ||= SearchTermExtractor.call(occupation_standards_search_params)
  end

  def standards_scope
    OccupationStandard.includes(:organization, :work_processes, registration_agency: :state, occupation: :onet)
  end
end
