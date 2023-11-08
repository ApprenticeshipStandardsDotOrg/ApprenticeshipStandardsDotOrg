namespace :after_party do
  desc "Deployment task: reindex_occupation_standards"
  task reindex_occupation_standards: :environment do
    puts "Running deploy task 'reindex_occupation_standards'"

    OccupationStandard.__elasticsearch__.create_index!(force: true)
    OccupationStandard.import

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
