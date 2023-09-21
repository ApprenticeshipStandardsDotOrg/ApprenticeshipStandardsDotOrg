class OccupationsController < ApplicationController
  def index
    es_response = OccupationElasticsearchQuery.new(
      search_params: params.permit(:q).to_h
    ).call
    occupations = es_response.records.to_a
    render json: OccupationBlueprint.render(occupations)
  end
end
