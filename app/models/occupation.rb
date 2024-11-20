class Occupation < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearchable

  has_many :competency_options, as: :resource
  has_many :occupation_standards

  belongs_to :onet, optional: true

  validates :title, presence: true

  delegate :code, to: :onet, prefix: true, allow_nil: true

  index_name "occupations_#{Rails.env}"
  number_of_shards = Rails.env.production? ? 2 : 1
  es_settings = {
    index: {
      number_of_shards: number_of_shards,
      analysis: {
        tokenizer: {
          autocomplete_tokenizer: {
            type: "edge_ngram",
            min_gram: 2,
            max_gram: 20,
            token_chars: ["letter", "digit", "punctuation"]
          }
        },
        analyzer: {
          autocomplete: {
            tokenizer: "autocomplete_tokenizer",
            filter: ["lowercase"]
          },
          autocomplete_search: {
            tokenizer: "standard",
            filter: ["lowercase"]
          }
        }
      }
    }
  }

  settings(es_settings) do
    mappings dynamic: false do
      indexes :title, type: :text, analyzer: :autocomplete, search_analyzer: :autocomplete_search
      indexes :rapids_code, type: :text, analyzer: :autocomplete, search_analyzer: :autocomplete_search
      indexes :onet_code, type: :text, analyzer: :autocomplete, search_analyzer: :autocomplete_search
    end
  end

  def as_indexed_json(_ = {})
    as_json(
      only: [:title, :rapids_code]
    ).merge(
      onet_code: onet_code
    )
  end

  def display_for_typeahead
    title.strip
  end

  def to_s
    "#{title} (#{rapids_code})"
  end
end
