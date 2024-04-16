module RAPIDS
  class WorkProcess
    class << self
      def initialize_from_response(work_process_data, ojt_type: nil)
        tasks = work_process_data["tasks"]
        tasks_titles = tasks.first.split(/\s?;\s?/)

        work_process = ::WorkProcess.new(
          title: work_process_data["title"],
          minimum_hours: work_process_data["minHours"],
          maximum_hours: work_process_data["maxHours"]
        )

        if competencies_available?(tasks_titles)
          if ojt_type == :time
            work_process.description = tasks_titles.join("; ")
          else
            competencies = process_competencies(tasks_titles)
            work_process.competencies = competencies
          end
        end

        work_process
      end

      private

      def competencies_available?(tasks_titles)
        tasks_titles.any?
      end

      def process_competencies(tasks_titles)
        tasks_titles.map.with_index do |task_title, index|
          Competency.initialize_from_response({
            "title" => task_title,
            "sort_order" => index
          })
        end
      end
    end
  end
end
