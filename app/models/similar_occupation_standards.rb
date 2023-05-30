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
    OccupationStandard.__elasticsearch__.search(query).records
  end

  private

  def query
    {
      size: RESULTS_SIZE,
      query: {
        more_like_this: {
          fields: ["title", "work_processes.title"],
          like: [
            {
              _index: OccupationStandard.index_name,
              _id: occupation_standard.id
            }
          ],
          min_term_freq: 1,
          analyzer: "snowball"
        }
      }
    }
  end
end
