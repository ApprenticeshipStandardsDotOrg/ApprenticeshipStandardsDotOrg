namespace :after_party do
  desc "Deployment task: backpopulate_work_processes_compentency_counter_cache"
  task backpopulate_work_processes_compentency_counter_cache: :environment do
    puts "Running deploy task 'backpopulate_work_processes_compentency_counter_cache'"

    WorkProcess.find_each do |work_process|
      WorkProcess.reset_counters(work_process.id, :competencies)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
