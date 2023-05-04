module WorkProcessesHelper
  def hours_range(work_process)
    [work_process.minimum_hours, work_process.maximum_hours].compact.uniq.join("-")
  end

  def hours_in_human_format(hours)
    number_to_human(
      hours,
      format: "%n%u",
      precision: 2,
      units:
      {
        thousand: "K"
      }
    )
  end
end
