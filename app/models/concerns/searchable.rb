module Searchable
  extend ActiveSupport::Concern

  ngram_filter = {type: "ngram", min_gram: 2, max_gram: 3}
  ngram_analyzer = {
    type: "custom",
    tokenizer: "standard",
    filter: %w[lowercase asciifolding ngram_filter]
  }
  whitespace_analyzer = {
    type: "custom",
    tokenizer: "whitespace",
    filter: %w[lowercase asciifolding]
  }

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings analysis: {
      filter: {
        ngram_filter: ngram_filter
      },
      analyzer: {
        ngram_analyzer: ngram_analyzer,
        whitespace_analyzer: whitespace_analyzer
      }
    }

    mapping do
    end
  end
end
