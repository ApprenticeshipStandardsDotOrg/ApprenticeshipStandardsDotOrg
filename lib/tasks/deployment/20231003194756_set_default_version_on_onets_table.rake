namespace :after_party do
  desc "Deployment task: set_default_version_on_onets_table"
  task set_default_version_on_onets_table: :environment do
    puts "Running deploy task 'set_default_version_on_onets_table'"

    Onet.update_all(version: "2019")

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
