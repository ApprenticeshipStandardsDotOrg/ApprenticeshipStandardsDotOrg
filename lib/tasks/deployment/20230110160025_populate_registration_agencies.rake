namespace :after_party do
  desc "Deployment task: populate_registration_agencies"
  task populate_registration_agencies: :environment do
    puts "Running deploy task 'populate_registration_agencies'"

    filename = File.join(Rails.root, "lib", "tasks", "files", "registration_agencies.csv")
    CSV.foreach(filename, headers: true) do |row|
      state_name = row["state_name"]
      Rails.error.handle(context: {state_name: state_name}) do
        state = State.find_by(name: state_name)
        RegistrationAgency.find_or_create_by!(
          state: state,
          agency_type: row["type"].downcase.to_sym
        )
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
