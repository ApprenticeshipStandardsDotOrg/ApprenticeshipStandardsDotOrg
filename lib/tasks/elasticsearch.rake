require "elasticsearch_wrapper/synonyms"

namespace :elasticsearch do
  desc "Create Synonym Set on ES"
  task create_synonym_set: :environment do
    unless Rails.env.production?
      uri = URI("http://localhost:9200/_synonyms/dynamic_synonyms_#{Rails.env}")
      resp = Net::HTTP.get_response(uri)

      if resp.code == "200"
        puts "Index already exists"
      else
        puts "Creating index"
        synonym = Synonym.create_with(synonyms: "User experience").find_or_create_by(
          word: "UX"
        )
        ElasticsearchWrapper::Synonyms.create_set(
          value: synonym.to_elasticsearch_value,
          rule_id: synonym.id
        )
      end
    end
  end
end
