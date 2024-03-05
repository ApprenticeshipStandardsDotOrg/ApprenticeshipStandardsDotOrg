class WorkProcessExtraction
  # def self.extract(occupation_standard:, description:, hour_bounds:, competency_data: nil)
  #   new(occupation_standard:, competency_data:, description:, hour_bounds:).extract
  # end

  # def initialize(occupation_standard:, description:, hour_bounds:, competency_data: nil)
  #   @occupation_standard = occupation_standard
  #   @competency_data = competency_data
  #   @description = description
  #   @minimum_hours = hour_bounds.first
  #   @maximum_hours = hour_bounds.last
  # end

  # def extract
  #   work_process = WorkProcess.find_or_initialize_by(
  #     occupation_standard:,
  #     title: description.presence
  #   )
  #   work_process.update!(description:, minimum_hours:, maximum_hours:)

  #   create_or_update_competency(work_process)
  # end

  # private

  # attr_reader :occupation_standard, :competency_data, :description, :maximum_hours, :minimum_hours

  # def create_or_update_competency(work_process)
  #   return unless competency_data.present?

  #   Competency.find_or_initialize_by(
  #     sort_order: competency_data[:sort_order],
  #     work_process:
  #   ).tap do |competency|
  #     competency.update!(title: competency_data[:skill_title])
  #   end
  # end
end
