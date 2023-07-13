class SimilarOccupationStandards
  attr_reader :occupation_standard, :debug

  RESULTS_SIZE = 5
  MINIMUM_SCORE = 0.2

  def self.similar_to(occupation_standard, debug = false)
    new(occupation_standard, debug).similar_to
  end

  def initialize(occupation_standard, debug = false)
    @occupation_standard = occupation_standard
    @debug = debug
  end

  def similar_to
    response = OccupationStandard.__elasticsearch__.search(query)
    if debug
      puts "QUERY"
      puts response.search.definition[:body][:query].to_json
      puts "HITS: #{response.results.total}"
      response.results.each do |result|
        puts "#{result._id}: #{result._score}"
      end
    end
    response.records.to_a
  end

  private

  def query
    {
      size: RESULTS_SIZE,
      min_score: MINIMUM_SCORE,
      query: {
        bool: {
          should: [
            {match: {
              title: {query: occupation_standard.title, boost: 5}
            }},
            {match: {
              work_process_titles: {
                query: occupation_standard.work_processes.pluck(:title).to_sentence,
                boost: 5
              }
            }},
            {match: {
              ojt_type: {query: occupation_standard.ojt_type, boost: 0.5}
            }},
            {match: {
              state: {query: occupation_standard.registration_agency&.state&.abbreviation}
            }}
          ],
          minimum_should_match: 1,
          must_not: [
            {
              term: {
                _id: occupation_standard.id
              }
            }
          ]
        }
      }
    }
  end
end
