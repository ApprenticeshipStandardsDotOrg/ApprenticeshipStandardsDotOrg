namespace :after_party do
  desc 'Deployment task: create_national_registration_agency'
  task create_national_registration_agency: :environment do
    puts "Running deploy task 'create_national_registration_agency'"

    RegistrationAgency.find_or_create_by!(
      agency_type: :oa
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end