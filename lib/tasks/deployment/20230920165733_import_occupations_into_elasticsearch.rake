namespace :after_party do
  desc "Deployment task: import_occupations_into_elasticsearch"
  task import_occupations_into_elasticsearch: :environment do
    puts "Running deploy task 'import_occupations_into_elasticsearch'"

    Occupation.__elasticsearch__.create_index!
    Occupation.import

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
