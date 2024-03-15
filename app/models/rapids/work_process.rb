module RAPIDS
  class WorkProcess
    class << self
      def initialize_from_response(work_process_data)
        tasks = work_process_data["tasks"]

        work_process = ::WorkProcess.new(
          title: work_process_data["title"],
          minimum_hours: work_process_data["minHours"],
          maximum_hours: work_process_data["maxHours"]
        )

        if competencies_available?(tasks)
          competencies = process_competencies(tasks)
          work_process.competencies = competencies
        end

        work_process
      end

      private

      def competencies_available?(tasks)
        tasks&.first&.present?
      end

      def process_competencies(tasks)
        tasks_titles = tasks.first.split(/\s?;\s?/)
        tasks_titles.map do |task_title|
          Competency.initialize_from_response({
            "title" => task_title
          })
        end
      end
    end
  end
end
