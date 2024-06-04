namespace :after_party do
  desc "Deployment task: remove_pending_uncategorized_imports"
  task remove_pending_uncategorized_imports: :environment do
    puts "Running deploy task 'remove_pending_uncategorized_imports'"

    # Imports::Uncategorized should never have status pending. Fortunately
    # when we accidentally created duplicate records, we set the dups
    # as status pending. Deleting them all here.
    Imports::Uncategorized.pending.destroy_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
