namespace :after_party do
  desc "Deployment task: cleanup_work_processes"
  task cleanup_work_processes: :environment do
    puts "Running deploy task 'cleanup_work_processes'"

    WorkProcess.where(
      sort_order: nil,
      title: nil,
      description: nil,
      default_hours: nil,
      minimum_hours: nil,
      maximum_hours: nil
    ).find_each do |work_process|
      if work_process.competencies.empty?
        work_process.destroy!
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
