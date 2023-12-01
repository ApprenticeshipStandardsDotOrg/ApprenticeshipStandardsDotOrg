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

  def work_process_accordion_class(work_process)
    if work_process.has_details_to_display?
      "accordion"
    end
  end

  def competencies_count_display_class(work_process)
    if work_process.competencies_count.positive?
      "visible"
    else
      "invisible"
    end
  end

  def work_process_hours_display_class(work_process)
    if work_process.hours.present? && work_process.occupation_standard_work_processes_hours.positive?
      "visible"
    else
      "invisible"
    end
  end
end
