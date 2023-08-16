require "elasticsearch/dsl"

class OccupationStandardElasticsearchQuery
  include Elasticsearch::DSL

  attr_reader :search_params, :debug

  def initialize(search_params:, debug: false)
    @search_params = search_params
    @debug = debug
  end

  def call
    definition = search do
      query do
        bool do
          if search_params[:state_id].present?
            filter do
              term state_id: search_params[:state_id]
            end
          end
          if search_params[:state].present?
            filter do
              term state: search_params[:state].upcase
            end
          end
          if search_params[:national_standard_type].present?
            must do
              bool do
                search_params[:national_standard_type].keys.each do |type|
                  should do
                    match national_standard_type: {
                      query: type
                    }
                  end
                end
                minimum_should_match 1
              end
            end
          end
          if search_params[:ojt_type].present?
            must do
              bool do
                search_params[:ojt_type].keys.each do |type|
                  should do
                    match ojt_type: {
                      query: type
                    }
                  end
                end
                minimum_should_match 1
              end
            end
          end
          if search_params[:q].present?
            q = search_params[:q]
            must do
              bool do
                should do
                  wildcard title: {
                    value:"*#{q.downcase}*"
                  }
                end
                should do
                  wildcard rapids_code: {
                    value: "*#{escape_autocomplete_terms(q)}*"
                  }
                end
                should do
                  wildcard onet_code: {
                    value: "*#{escape_autocomplete_terms(q)}*"
                  }
                end
                should do
                  match industry_name: {
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
    response = OccupationStandard.__elasticsearch__.search(definition)
    debug_query(response)
    response
  end

  private

  def escape_autocomplete_terms(q)
    q.gsub(/\.|-|,/, "*").downcase
  end

  def debug_query(response)
    if debug
      puts "QUERY"
      puts response.search.definition[:body][:query].to_json
      puts "HITS: #{response.results.total}"
      response.results.each do |result|
#        puts result.inspect
        puts "#{result._id}: #{result._score}"
      end
    end
  end
end
