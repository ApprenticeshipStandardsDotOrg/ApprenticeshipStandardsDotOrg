module RAPIDS
  class WorkProcess
    def self.initialize_from_response(work_process_data)
      ::WorkProcess.new(
        title: work_process_data["title"],
        minimum_hours: work_process_data["minHours"],
        maximum_hours: work_process_data["maxHours"]
      )
    end
  end
end
