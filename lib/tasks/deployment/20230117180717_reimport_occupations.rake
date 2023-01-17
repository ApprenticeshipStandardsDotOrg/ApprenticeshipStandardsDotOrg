namespace :after_party do
  desc 'Deployment task: reimport_occupations'
  task reimport_occupations: :environment do
    puts "Running deploy task 'reimport_occupations'"

    Occupation.destroy_all
    ENV["FORCE"] = "true"
    Rake::Task["occupation:onet_code_scraper"].invoke
    Rake::Task["occupation:rapids_codes_scraper"].invoke

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
