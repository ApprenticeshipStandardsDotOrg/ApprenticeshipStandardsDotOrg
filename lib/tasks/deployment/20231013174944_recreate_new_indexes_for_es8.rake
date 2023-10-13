namespace :after_party do
  desc "Deployment task: recreate_new_indexes_for_es8"
  task recreate_new_indexes_for_es8: :environment do
    puts "Running deploy task 'recreate_new_indexes_for_es8'"

    OccupationStandard.__elasticsearch__.create_index!
    OccupationStandard.import

    Occupation.__elasticsearch__.create_index!
    OccupationStandard.import

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
