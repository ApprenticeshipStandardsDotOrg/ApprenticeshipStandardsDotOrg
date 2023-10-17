RSpec.configure do |config|
  config.before :each, elasticsearch: true do
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
