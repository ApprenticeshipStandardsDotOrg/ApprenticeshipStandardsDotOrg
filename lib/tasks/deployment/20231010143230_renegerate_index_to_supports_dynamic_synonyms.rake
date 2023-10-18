require "elasticsearch_wrapper/synonyms"

namespace :after_party do
  desc "Deployment task: renegerate_index_to_supports_dynamic_synonyms"
  task renegerate_index_to_supports_dynamic_synonyms: :environment do
    puts "Running deploy task 'renegerate_index_to_supports_dynamic_synonyms'"

    OccupationStandard.__elasticsearch__.create_index!(force: true)
    OccupationStandard.import

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
