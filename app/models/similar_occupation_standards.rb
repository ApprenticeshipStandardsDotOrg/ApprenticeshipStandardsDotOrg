class SimilarOccupationStandards
  attr_reader :occupation_standard

  def self.similar_to(occupation_standard)
    new(occupation_standard).top_five
  end

  def initialize(occupation_standard)
    @occupation_standard = occupation_standard
  end

  def top_five
    OccupationStandard.__elasticsearch__.search(query).records
  end

  private

  def query
    {
      size: 5,
      query: {
        more_like_this: {
          fields: ["title"],
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
