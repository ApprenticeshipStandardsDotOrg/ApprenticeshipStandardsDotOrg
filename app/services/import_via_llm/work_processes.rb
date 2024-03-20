module ImportViaLLM
  class WorkProcesses
    def self.import(...) = new(...).import

    def initialize(occupation_standard:, description:, hour_bounds:)
      @occupation_standard = occupation_standard
      @description = description
      @minimum_hours = hour_bounds.first
      @maximum_hours = hour_bounds.last
    end

    def import
      work_process = WorkProcess.find_or_initialize_by(
        occupation_standard:,
        title: description.presence
      )
      work_process.update!(description:, minimum_hours:, maximum_hours:)
      work_process
    end

    private

    attr_reader :occupation_standard, :description, :maximum_hours, :minimum_hours
  end
end
