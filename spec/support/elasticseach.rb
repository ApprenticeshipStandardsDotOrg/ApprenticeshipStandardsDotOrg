require "elasticsearch/extensions/test/cluster"

RSpec.configure do |config|
  config.before :all, elasticsearch: true do
    Elasticsearch::Extensions::Test::Cluster.start unless
    Elasticsearch::Extensions::Test::Cluster.running?(port: 9200)
  end

  config.before :each, elasticsearch: true do
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__)
        begin
          model.__elasticsearch__.create_index!
          model.__elasticsearch__.refresh_index!
        rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
          puts "There was an error creating the elasticsearch index
                for #{model.name}: #{e.inspect}"
        end
      end
    end
  end

  config.after :suite do
    Elasticsearch::Extensions::Test::Cluster.stop if
      Elasticsearch::Extensions::Test::Cluster.running?(port: 9200)
  end

  config.after :each, elasticsearch: true do
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__)
        begin
          model.__elasticsearch__.delete_index!
        rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
          puts "There was an error removing the elasticsearch index
                for #{model.name}: #{e.inspect}"
        end
      end
    end
  end
end
