namespace :after_party do
  desc "Deployment task: rebuild_occupation_standards_to_add_headline"
  task rebuild_occupation_standards_to_add_headline: :environment do
    puts "Running deploy task 'rebuild_occupation_standards_to_add_headline'"

    OccupationStandard.__elasticsearch__.create_index!(force: true)
    OccupationStandard.import

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
