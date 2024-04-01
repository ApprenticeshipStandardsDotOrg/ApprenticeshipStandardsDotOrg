class ImportDataFromRAPIDSJob < ApplicationJob
  queue_as :default

  PER_PAGE_SIZE = 50

  def perform
    service = RAPIDS::API.call
    start_index = 1

    loop do
      response = service.work_processes(
        batchSize: PER_PAGE_SIZE,
        startIndex: start_index
      )
      parsed_response = response.parsed
      occupation_standards = process_api_response(parsed_response)
      occupation_standards.map(&:save)
      total_records = parsed_response["totalCount"]
      start_index += PER_PAGE_SIZE

      break if start_index > total_records
    end
  end

  def process_api_response(response)
    response["wps"].map do |occupation_standard_response|
      occupation_standard = process_occupation_standard(occupation_standard_response)

      occupation_standard.work_processes = process_work_processes(
        occupation_standard_response["dwas"],
        occupation_standard
      )

      occupation_standard
    end
  end

  def process_occupation_standard(occupation_standard_response)
    RAPIDS::OccupationStandard.initialize_from_response(
      occupation_standard_response
    )
  end

  def process_work_processes(work_processes_response, occupation_standard)
    work_processes_response.filter_map do |work_process_response|
      work_process = RAPIDS::WorkProcess.initialize_from_response(
        work_process_response
      )
      work_process.occupation_standard = occupation_standard
      work_process if work_process.valid?
    end
  end
end
