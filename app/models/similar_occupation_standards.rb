class SimilarOccupationStandards
  attr_reader :occupation_standard

  RESULTS_SIZE = 5

  def self.similar_to(occupation_standard)
    new(occupation_standard).similar_to
  end

  def initialize(occupation_standard)
    @occupation_standard = occupation_standard
  end

  def similar_to
    search = OccupationStandard.__elasticsearch__.search(query)
    ids_order = search.response["hits"]["hits"].map { |record| record["_id"] }
    result = search.records.in_order_of(:id, ids_order)
    result
  end

  private

  def query
    {
      size: RESULTS_SIZE,
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
