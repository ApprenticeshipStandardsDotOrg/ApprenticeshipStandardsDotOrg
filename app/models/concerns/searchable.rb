module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    mapping do
    end

    def self.search(query)
      params = {
        query: {
          match: {
            title: query
          }
        }
      }

      __elasticsearch__.search(params)
    end
  end
end
