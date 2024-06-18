namespace :after_party do
  desc "Deployment task: mark_dataimports_from_rapids_as_complete"
  task mark_dataimports_from_rapids_as_complete: :environment do
    puts "Running deploy task 'mark_dataimports_from_rapids_as_complete'"

    DataImport.includes(:file_attachment).where(
      user_id: nil,
      file_attachment: {id: nil}
    ).update_all(status: :completed)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
