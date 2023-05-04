module WorkProcessesHelper
  def hours_in_human_format(hours)
    number_to_human(
      hours,
      format: '%n%u',
      precision: 2,
      units:
      {
        thousand: 'K'
      }
    )
  end
end
