class Synonym < ApplicationRecord
  COMMA_SEPARATED_LIST_REGEX = /^([a-zA-Z \/\-\_]*,?)+$/
  validate :synonyms_list_valid?

  def self.to_elasticsearch_setting
    all.map do |record|
      "#{record.word},#{record.synonyms}"
    end
  end

  private

  def synonyms_list_valid?
    unless COMMA_SEPARATED_LIST_REGEX.match(synonyms)
      errors.add(:synonyms, "Invalid format. It must be a comma-separated list or a single term")
    end
  end
end
