namespace :after_party do
  desc "Deployment task: populate_related_job_titles"
  task populate_related_job_titles: :environment do
    puts "Running deploy task 'populate_related_job_titles'"

    Onet.find_each do |onet|
      OnetWebService.new(onet).call
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
