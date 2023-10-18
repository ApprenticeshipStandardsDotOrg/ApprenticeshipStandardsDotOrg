require "elasticsearch_wrapper/synonyms"

namespace :elasticsearch do
  desc "Create Synonym Set on ES"
  task create_synonym_set: :environment do
    synonym = Synonym.create!(word: "UX", synonyms: "User experience")
    ElasticsearchWrapper::Synonyms.create_set(
      value: synonym.to_elasticsearch_value,
      rule_id: synonym.id
    )
  end
end
