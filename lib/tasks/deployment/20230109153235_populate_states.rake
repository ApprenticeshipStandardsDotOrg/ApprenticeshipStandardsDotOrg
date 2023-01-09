require "csv"

namespace :after_party do
  desc "Deployment task: populate_states"
  task populate_states: :environment do
    puts "Running deploy task 'populate_states'"

    filename = File.join(Rails.root, "lib", "tasks", "files", "state.txt")
    CSV.foreach(filename, headers: true, col_sep: "|") do |row|
      State.find_or_create_by!(
        name: row["STATE_NAME"],
        abbreviation: row["STUSAB"]
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
