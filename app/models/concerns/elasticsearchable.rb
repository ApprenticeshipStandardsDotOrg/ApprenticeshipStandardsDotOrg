module Elasticsearchable
  extend ActiveSupport::Concern

  included do
    after_commit on: [:create] do
      unless elasticsearch_disabled?
        __elasticsearch__.index_document
      end
    end

    after_commit on: [:update] do
      update_document
    end

    after_commit on: [:destroy] do
      unless elasticsearch_disabled?
        __elasticsearch__.delete_document
      end
    end

    def update_document
      unless elasticsearch_disabled?
        __elasticsearch__.update_document
      end
    end
  end

  def elasticsearch_disabled?
    Rails.env.test? && RSpec.configuration.elasticsearch_disabled?
  end
end
