namespace :after_party do
  desc "Deployment task: reindex_occupations"
  task reindex_occupations: :environment do
    puts "Running deploy task 'reindex_occupations'"

    Occupation.__elasticsearch__.create_index!(force: true)
    Occupation.import

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
