module Elasticsearchable
  extend ActiveSupport::Concern

  included do
    after_commit on: [:create] do
      __elasticsearch__.index_document unless self.class.elasticsearch_disabled?
    end

    after_commit on: [:update] do
      unless elasticsearch_disabled?
        __elasticsearch__.update_document
      end
    end

    after_commit on: [:destroy] do
      __elasticsearch__.delete_document unless self.class.elasticsearch_disabled?
    end
  end

  class_methods do
    def elasticsearch_disabled?
      Rails.env.test? && !self.__elasticsearch__.index_exists?
    end
  end
end
