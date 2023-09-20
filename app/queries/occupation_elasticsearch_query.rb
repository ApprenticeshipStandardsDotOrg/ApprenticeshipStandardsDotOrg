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
      query do
        bool do
          must match_all: {}
          if search_params[:q].present?
            must do
              match title: {
                query: search_params[:q]
              }
            end
          end
        end
      end
    end
    response = Occupation.__elasticsearch__.search(
      definition,
      from: offset
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
