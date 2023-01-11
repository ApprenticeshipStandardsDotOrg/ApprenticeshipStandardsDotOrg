namespace :after_party do
  desc "Deployment task: populate_onet_and_rapids_codes"
  task populate_onet_and_rapids_codes: :environment do
    puts "Running deploy task 'populate_onet_and_rapids_codes'"

    if Rails.env.development?
      ENV["FORCE"] = "true"
      Rake::Task["occupation:onet_code_scraper"].invoke
      Rake::Task["occupation:rapids_codes_scraper"].invoke
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
