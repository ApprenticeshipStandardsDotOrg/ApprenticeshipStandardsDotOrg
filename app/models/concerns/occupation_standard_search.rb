module OccupationStandardSearch
  extend ActiveSupport::Concern

  def self.search(query)
    params = search_query(query)
    __elasticsearch__.search(params)
  end

  def search_query(query)
    {
      size: 5,
      query: {
        function_score: {
          query: {
            bool: {
              must: [multi_match(query)]
            }
          }
        }
      }
    }
  end

  def multi_match(query)
    {
      multi_match: {
        query: query,
        fields: %w[title],
        fuzziness: "auto"
      }
    }
  end
end
