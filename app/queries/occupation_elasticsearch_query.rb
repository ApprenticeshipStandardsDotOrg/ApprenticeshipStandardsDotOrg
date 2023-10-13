require "elasticsearch/dsl"

class OccupationElasticsearchQuery
  include Elasticsearch::DSL

  attr_reader :search_params, :offset

  def initialize(search_params:, offset: 0)
    @search_params = search_params
    @offset = offset
  end

  def call
    definition = search do
      query do
        bool do
          must match_all: {}
          if search_params[:q].present?
            q = search_params[:q]
            must do
              bool do
                should do
                  match title: {
                    query: q
                  }
                end
                should do
                  match rapids_code: {
                    query: q
                  }
                end
                should do
                  match onet_code: {
                    query: q
                  }
                end
                minimum_should_match 1
              end
            end
          end
        end
      end
    end
    Occupation.__elasticsearch__.search(
      definition,
      from: offset
    )
  end
end
