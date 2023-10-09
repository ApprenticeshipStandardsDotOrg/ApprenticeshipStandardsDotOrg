require "elasticsearch/dsl"

class OccupationStandardElasticsearchQuery
  include Elasticsearch::DSL

  attr_reader :search_params, :offset, :debug

  def initialize(search_params:, offset: 0, debug: true)
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
      collapse :headline do
        inner_hits :children
        sort do
          by :_score, order: :desc
          by :created_at, order: :desc
        end
      end
      query do
        bool do
          must match_all: {}
          must do
            exists field: "work_process_titles"
          end
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
          if search_params[:onet_prefix].present?
            filter do
              match "onet_code.prefix": search_params[:onet_prefix]
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
                  match_phrase title: {
                    query: q,
                    boost: 2,
                    slop: 1
                  }
                end
                should do
                  match title: {
                    query: q,
                    boost: 1.5
                  }
                end
                should do
                  match related_job_titles: {
                    query: q,
                    boost: 1.2
                  }
                end
                should do
                  match industry_name: {
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
          should do
            term national_standard_type: "occupational_framework"
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
        puts "PARENT: #{result._id}: #{result._score}"
        result.inner_hits.children.each do |child|
          child[1].hits.each do |hit|
            puts "\tCHILD ID: #{hit._id}: #{hit._score}"
          end
        end
      end
    end
  end
end
