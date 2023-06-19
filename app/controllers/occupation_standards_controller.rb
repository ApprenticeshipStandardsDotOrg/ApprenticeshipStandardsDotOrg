class OccupationStandardsController < ApplicationController
  def index
    @occupation_standards_search = OccupationStandardQuery::Container.new(search_term_params: search_term_params)

    @occupation_standards = OccupationStandardQuery.run(
      standards_scope,
      search_term_params
    )

    @pagy, @occupation_standards = pagy(@occupation_standards)
    @search_term = search_term
  end

  def show
    @occupation_standard = OccupationStandard.find(params[:id])

    respond_to do |format|
      format.html {}
      format.docx do
        export = OccupationStandardExport.new(@occupation_standard)

        send_data(export.call, filename: export.filename)
      end
    end
  end

  private

  def search_term_params
    params.permit(
      :q,
      :state_id,
      :state_abbreviation,
      ojt_type: [:time, :hybrid, :competency],
      national_standard_type: [
        :program_standard, :guideline_standard, :occupational_framework
      ]
    )
  end

  def search_term
    search_term_for_state || generic_search_term
  end

  def search_term_for_state
    if search_term_params[:state_abbreviation].present?
      State.find_by(
        abbreviation: search_term_params[:state_abbreviation].upcase
      )&.name
    end
  end

  def generic_search_term
    search_term_params[:q]
  end

  def standards_scope
    OccupationStandard.includes(:organization, :work_processes, registration_agency: :state, occupation: :onet)
  end
end
