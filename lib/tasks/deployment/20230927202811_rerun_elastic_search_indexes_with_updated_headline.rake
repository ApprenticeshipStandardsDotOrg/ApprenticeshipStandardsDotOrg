namespace :after_party do
  desc "Deployment task: rerun_elastic_search_indexes_with_updated_headline"
  task rerun_elastic_search_indexes_with_updated_headline: :environment do
    puts "Running deploy task 'rerun_elastic_search_indexes_with_updated_headline'"

    OccupationStandard.__elasticsearch__.create_index!(force: true)
    OccupationStandard.import

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
