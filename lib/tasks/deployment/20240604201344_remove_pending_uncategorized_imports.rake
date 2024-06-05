namespace :after_party do
  desc "Deployment task: remove_pending_uncategorized_imports"
  task remove_pending_uncategorized_imports: :environment do
    puts "Running deploy task 'remove_pending_uncategorized_imports'"

    # Imports::Uncategorized should never have status pending. Fortunately
    # when we accidentally created duplicate records, we set the dups
    # as status pending. Deleting any where the courtesy_notification is not
    # pending (meaning they came in through a scraper). Currently the
    # courtesy_notifcation: pending count on prod is 0, but just in case any
    # files are uploaded in the meantime, those imports should be set to status
    # unfurled.
    Imports::Uncategorized.pending.where.not(courtesy_notification: :pending).destroy_all

    Imports::Uncategorized.pending.where(courtesy_notification: :pending).each do |import|
      import.unfurled!
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
