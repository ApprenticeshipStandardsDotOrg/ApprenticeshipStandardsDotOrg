module WorkProcessesHelper
  def hours_range(hours, fallback)
    hours = [hours, fallback].compact.first
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
    hours_range(maximum_hours, minimum_hours)
  end
end
