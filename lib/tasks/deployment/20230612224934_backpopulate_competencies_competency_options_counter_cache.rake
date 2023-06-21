namespace :after_party do
  desc "Deployment task: backpopulate_competencies_competency_options_counter_cache"
  task backpopulate_competencies_competency_options_counter_cache: :environment do
    puts "Running deploy task 'backpopulate_competencies_competency_options_counter_cache'"

    Competency.find_each do |competency|
      Competency.reset_counters(competency.id, :competency_options)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
