require "elasticsearch_wrapper/synonyms"

class Synonym < ApplicationRecord
  COMMA_SEPARATED_LIST_REGEX = /^([a-zA-Z \/\-_]*,?)+$/
  validate :synonyms_list_valid?
  validates :word, :synonyms, presence: true

  def to_elasticsearch_value
    "#{word},#{synonyms}"
  end

  def add_to_elastic_search_synonyms
    ElasticsearchWrapper::Synonyms.add(
      rule_id: id,
      value: to_elasticsearch_value
    )
  end

  def remove_from_elastic_search_synonyms
    ElasticsearchWrapper::Synonyms.remove(
      rule_id: id
    )
  end

  private

  def synonyms_list_valid?
    unless COMMA_SEPARATED_LIST_REGEX.match(synonyms)
      errors.add(:synonyms, "Invalid format. It must be a comma-separated list or a single term")
    end
  end
end
