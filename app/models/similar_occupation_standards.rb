require "elasticsearch/dsl"

class SimilarOccupationStandards
  include Elasticsearch::DSL

  attr_reader :occupation_standard

  RESULTS_SIZE = 5
  MINIMUM_SCORE = 0.2

  def self.similar_to(occupation_standard)
    new(occupation_standard).similar_to
  end

  def initialize(occupation_standard)
    @occupation_standard = occupation_standard
  end

  def similar_to
    response = OccupationStandard.__elasticsearch__.search(query(occupation_standard))
    response.records.to_a
  end

  private

  def query(occupation_standard)
    search do
      size RESULTS_SIZE
      min_score MINIMUM_SCORE
      query do
        bool do
          should do
            match title: {
              query: occupation_standard.title,
              boost: 5
            }
          end
          should do
            match work_process_titles: {
              query: occupation_standard.work_processes.pluck(:title).to_sentence
            }
          end
          should do
            match ojt_type: {
              query: occupation_standard.ojt_type,
              boost: 0.5
            }
          end
          if occupation_standard.registration_agency&.state
            should do
              match state: {
                query: occupation_standard.state_abbreviation
              }
            end
          end
          minimum_should_match 1

          must_not do
            term _id: occupation_standard.id
          end
        end
      end
    end
  end
end
