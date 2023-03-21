namespace :after_party do
  desc "Deployment task: fix_changing_of_source_file_status_enum_value"
  task fix_changing_of_source_file_status_enum_value: :environment do
    puts "Running deploy task 'fix_changing_of_source_file_status_enum_value'"

    # Since one of the statuses was removed, update any source file that was not
    # pending to completed.
    SourceFile.where.not(status: :pending).update_all(status: :completed)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
