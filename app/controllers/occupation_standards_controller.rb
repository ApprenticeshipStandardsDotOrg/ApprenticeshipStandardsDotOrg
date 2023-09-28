class OccupationStandardsController < ApplicationController
  def index
    @page_title = "Occupations"
    puts  params.inspect
    puts  search_term_params.inspect

    if Flipper.enabled?(:use_elasticsearch_for_search)
      refine_search_params

      es_response = OccupationStandardElasticsearchQuery.new(
        search_params: search_term_params,
        offset: offset
      ).call
      @pagy = Pagy.new_from_elasticsearch_rails(
        es_response,
        items: Pagy::DEFAULT[:items],
        page: current_page
      )
      @occupation_standards = add_inner_hits_from_results(es_response.records)
    else
      @occupation_standards_search = OccupationStandardQuery::Container.new(
        search_term_params: search_term_params
      )

      occupation_standards = OccupationStandardQuery.run(
        standards_scope,
        search_term_params
      )
      @pagy, @occupation_standards = pagy(occupation_standards)
    end

    @search_term = search_term_params[:q]
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
      :onet_prefix,
      ojt_type: [:time, :hybrid, :competency],
      national_standard_type: [
        :program_standard, :guideline_standard, :occupational_framework
      ]
    )
  end

  def search_term_params
    @search_term_params ||= SearchTermExtractor.call(occupation_standards_search_params)
  end

  def refine_search_params
    if search_term_params[:onet_prefix].blank? && search_term_starts_with_letter?
      resp = OccupationStandardElasticsearchQuery.new(
        search_params: search_term_params
      ).call
      first_hit = resp.records.first
      if first_hit && first_hit.onet_code.present?
        search_term_params[:onet_prefix] = first_hit.onet_code
      end
    end
  end

  def search_term_starts_with_letter?
    search_term_params[:q].present? && search_term_params[:q].match?(/\A[a-zA-Z]/)
  end

  def standards_scope
    OccupationStandard.includes(:organization, :work_processes, registration_agency: :state, occupation: :onet)
  end

  def current_page
    params[:page].presence || 1
  end

  def offset
    (current_page.to_i - 1) * Pagy::DEFAULT[:items]
  end

  def add_inner_hits_from_results(occupation_standards)
    occupation_standards.map_with_hit do |occupation_standard, result|
      inner_hits = result.inner_hits["children"]["hits"]["hits"]
      if inner_hits.any?
        occupation_standard.inner_hits = InnerHit.from_result(inner_hits)
      end

      occupation_standard
    end
  end
end
