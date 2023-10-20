namespace :after_party do
  desc "Deployment task: generate_synonym_set"
  task generate_synonym_set: :environment do
    puts "Running deploy task 'generate_synonym_set'"

    client = Elasticsearch::Model.client
    begin client.synonyms.get_synonym(id: ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME)
          puts "Index already exists"
    rescue
      puts "Creating index and adding synonym set"
      synonym = Synonym.create_with(synonyms: "User experience").find_or_create_by(word: "UX")
      ElasticsearchWrapper::Synonyms.create_set(
        value: synonym.to_elasticsearch_value,
        rule_id: synonym.id
      )

      OccupationStandard.__elasticsearch__.create_index!
      OccupationStandard.import
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
