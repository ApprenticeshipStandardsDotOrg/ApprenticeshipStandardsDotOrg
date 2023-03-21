module WorkProcessesHelper
  def hours_range(work_process)
    [work_process.minimum_hours, work_process.maximum_hours].compact.uniq.join("-")
  end
end
