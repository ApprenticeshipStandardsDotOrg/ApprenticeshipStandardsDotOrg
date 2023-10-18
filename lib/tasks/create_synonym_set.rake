require "elasticsearch_wrapper/synonyms"

namespace :elasticsearch do
  desc "Create Synonym Set on ES"
  task create_synonym_set: :environment do
    ElasticsearchWrapper::Synonyms.create_set
  end
end
