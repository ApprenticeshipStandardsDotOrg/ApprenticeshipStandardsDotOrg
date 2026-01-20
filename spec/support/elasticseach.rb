RSpec.configure do |config|
  config.before(:suite) do
    client = Elasticsearch::Model.client
    # Check Elasticsearch version - Synonyms API is only available in 8.x+
    info = client.info.body
    version = info.dig("version", "number") || ""
    major_version = version.split(".").first.to_i

    if major_version < 8
      puts "Info: Elasticsearch #{version} detected. Synonyms API requires 8.x+. Skipping synonym setup."
      next
    end

    # The create Synonym Set endpoint is missing from the elasticsearch-rails
    # gem so putting in a dummy synonym for now using PUT, which will create the
    # set and add the synonym at the same time.
    client.synonyms.put_synonym(
      id: ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME,
      body: {synonyms_set: [{synonyms: "#{SecureRandom.hex}, #{SecureRandom.hex}"}]}
    )
  rescue => e
    # Skip Elasticsearch setup if not available or incompatible
    # This allows tests to run without Elasticsearch
    puts "Warning: Could not set up Elasticsearch synonyms: #{e.message}"
  end

  config.after(:suite) do
    client = Elasticsearch::Model.client
    # Check Elasticsearch version - Synonyms API is only available in 8.x+
    info = client.info.body
    version = info.dig("version", "number") || ""
    major_version = version.split(".").first.to_i

    if major_version < 8
      next
    end

    client.synonyms.delete_synonym(id: ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME)
  rescue => e
    # Skip cleanup if Elasticsearch is not available
    puts "Warning: Could not clean up Elasticsearch synonyms: #{e.message}"
  end

  config.before :each, elasticsearch: true do
    config.elasticsearch_disabled = false
    ApplicationRecord.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__)
        begin
          model.__elasticsearch__.delete_index!
        rescue
          # Do nothing. This is a cleanup in case the index already existed
        end

        begin
          model.__elasticsearch__.create_index!
        rescue Elastic::Transport::Transport::Errors::NotFound => e
          puts "There was an error creating the elasticsearch index
                for #{model.name}: #{e.inspect}"
        end
      end
    end
  end

  config.after :each, elasticsearch: true do
    config.elasticsearch_disabled = true
    ApplicationRecord.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__)
        begin
          model.__elasticsearch__.delete_index!
        rescue Elastic::Transport::Transport::Errors::NotFound => e
          puts "There was an error removing the elasticsearch index
                for #{model.name}: #{e.inspect}"
        end
      end
    end
  end
end
