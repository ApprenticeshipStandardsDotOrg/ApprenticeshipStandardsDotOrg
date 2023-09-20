class Occupation < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  has_many :competency_options, as: :resource

  belongs_to :onet, optional: true

  validates :title, presence: true

  delegate :code, to: :onet, prefix: true, allow_nil: true

  index_name "occupations_#{Rails.env}"
  number_of_shards = Rails.env.production? ? 2 : 1
  es_settings = {
    index: {
      number_of_shards: number_of_shards
    }
  }

  settings(es_settings) do
    mappings dynamic: false do
      indexes :title, type: :text, analyzer: :english
    end
  end

  def as_indexed_json(_ = {})
    as_json(
      only: [:title]
    )
  end

  def to_s
    "#{title} (#{rapids_code})"
  end
end
