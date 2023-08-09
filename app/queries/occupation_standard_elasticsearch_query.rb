require "elasticsearch/dsl"

class OccupationStandardElasticsearchQuery
  include Elasticsearch::DSL

  attr_reader :search_term_params, :debug

  def initialize(search_term_params, debug = false)
    @search_term_params = search_term_params
    @debug = debug
  end

  def do_search
    puts "search params"
    puts search_term_params
    definition = search do
      query do
        bool do
          must do
            if search_term_params[:state_id].present?
              filter do
                term state_id: search_term_params[:state_id]
              end
            end
            if search_term_params[:state].present?
              filter do
                term state: search_term_params[:state]
              end
            end
            if search_term_params[:national_standard_type].present?
              bool do
                search_term_params[:national_standard_type].keys.each do |type|
                  should do
                    match national_standard_type: {
                      query: type
                    }
                  end
                end
                minimum_should_match 1
              end
            end
            if search_term_params[:ojt_type].present?
              bool do
                search_term_params[:ojt_type].keys.each do |type|
                  should do
                    match ojt_type: {
                      query: type
                    }
                  end
                end
                minimum_should_match 1
              end
            end
            if search_term_params[:q].present?
              q = search_term_params[:q]
              bool do
                should do
                  match title: {
                    query: q
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
    if debug
      puts "DEFINITION"
      puts definition.to_hash
      puts "DEFINITION END"
      puts "QUERY"
      puts response.search.definition[:body][:query].to_json
      puts "HITS: #{response.results.total}"
      response.results.each do |result|
        puts "#{result._id}: #{result._score}"
      end
    end
    response.records
  end

  private

  def escape_autocomplete_terms(q)
    q.gsub(/\.|-|,/, "*")
  end
end
