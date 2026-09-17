require "elasticsearch/dsl"

class SimilarOccupationStandards
  include Elasticsearch::DSL

  attr_reader :occupation_standard

  RESULTS_SIZE = 5
  MINIMUM_SCORE = 0.2
  MAX_WORK_PROCESS_TITLES = 50

  def self.similar_to(occupation_standard)
    new(occupation_standard).similar_to
  end

  def initialize(occupation_standard)
    @occupation_standard = occupation_standard
  end

  def similar_to
    response = OccupationStandard.__elasticsearch__.search(query(occupation_standard))
    response.records.to_a
  rescue Elastic::Transport::Transport::Errors::BadRequest => error
    Rails.error.report(
      error,
      handled: true,
      context: {occupation_standard_id: occupation_standard.id}
    )
    []
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
          if work_process_titles.any?
            should do
              match work_process_titles: {
                query: work_process_titles.to_sentence
              }
            end
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

  def work_process_titles
    @work_process_titles ||= WorkProcess
      .where(occupation_standard_id: occupation_standard.id)
      .where.not(title: [nil, ""])
      .distinct
      .order(:title)
      .pluck(:title)
      .uniq { |title| title.squish.downcase }
      .first(MAX_WORK_PROCESS_TITLES)
  end
end
