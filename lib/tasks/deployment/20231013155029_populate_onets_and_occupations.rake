namespace :after_party do
  desc "Deployment task: populate_onets_and_occupations"
  task populate_onets_and_occupations: :environment do
    puts "Running deploy task 'populate_onets_and_occupations'"

    if Rails.env.development?
      puts "This task can take upwards of 6+ minutes to run..."
      ScrapeRAPIDSCode.new.call
      ScrapeOnetCodes.new.call
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
