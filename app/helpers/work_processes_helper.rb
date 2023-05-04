module WorkProcessesHelper
  def hours_in_human_format(hours)
    number_to_human(
      hours,
      format: '%n%u',
      precision: 2,
      units:
      {
        thousand: 'K',
        million: 'M',
        billion: 'B'
      }
    )
  end

  def hours_range_for_occupation(occupation_standard)
    minimum_hours = occupation_standard.work_processes.sum(&:minimum_hours)
    maximum_hours = occupation_standard.work_processes.sum(&:maximum_hours)
    hours = [maximum_hours, minimum_hours].compact.first
    hours_in_human_format(hours)
  end
end
