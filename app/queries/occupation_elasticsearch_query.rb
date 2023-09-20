require "elasticsearch/dsl"

class OccupationElasticsearchQuery
  include Elasticsearch::DSL

  attr_reader :search_params, :offset, :debug

  def initialize(search_params:, offset: 0, debug: false)
    @search_params = search_params
    @offset = offset
    @debug = debug
  end

  def call
    definition = search do
      sort do
        by :_score, order: :desc
        by :created_at, order: :desc
      end
      query do
        bool do
          must match_all: {}
          if search_params[:q].present?
            q = search_params[:q]
            must do
              match "title.typeahead": {
                query: q
              }
            end
          end
        end
      end
    end
    # Size and From must be passed here rather than defined in the query in
    # order for Pagy to work correctly.
    response = OccupationStandard.__elasticsearch__.search(
      definition,
      from: offset,
      size: Pagy::DEFAULT[:items]
    )
    debug_query(response)
    response
  end

  private

  def debug_query(response)
    if debug
      puts "BODY"
      puts response.search.definition[:body].to_json
      puts "HITS: #{response.results.total}"
      response.results.each do |result|
        #        puts result.inspect
        puts "#{result._id}: #{result._score}"
      end
    end
  end
end
