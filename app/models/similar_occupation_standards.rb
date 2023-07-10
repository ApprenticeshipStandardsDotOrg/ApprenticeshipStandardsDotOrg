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
    search = OccupationStandard.__elasticsearch__.search(query)
    if debug
      puts search.search.definition[:body][:query].to_json
    end
    search.records.to_a
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
            }},
            more_like_this: more_like_this
          ],
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

  def more_like_this
    {
      like: [
        {
          _index: OccupationStandard.index_name,
          _id: occupation_standard.id
        }
      ],
      min_term_freq: 1,
      analyzer: "snowball"
    }
  end
end
