class WorkProcessExtractorJob < ApplicationJob
  queue_as :default

  def perform(occupation_standard, competency_data)
    file = "/Users/nina/Documents/ApprenticeshipStandardsDotOrg/tmp/test3.pdf"
    reader = PDF::Reader.new(file)
    text = reader.pages[19..23].map { |page| page.text }

    prompt = "Could you identify the work processes and the hours spent in them in this document in a json with name of the process as key and hours as an array with the values of minimum and maximum hours? Use 'N/A' when there is no hour, and fill both values of the array with the same number when there is only one value for hour. #{text}"
    response = ChatGptGenerateText.new(prompt).call

    chatgpt_work_processes = JSON.parse(response)
    chatgpt_work_processes.each do |key, value|
      work_process = WorkProcess.find_or_initialize_by(
        occupation_standard: occupation_standard,
        title: key.presence
      )

      work_process.update!(
        description: key,
        minimum_hours: value.first,
        maximum_hours: value.last
      )

      create_or_update_competency(work_process, competency_data) if competency_data.present?
    end
  end

  private

  def create_or_update_competency(work_process, competency_data)
    Competency.find_or_initialize_by(
      sort_order: competency_data[:skill_title],
      work_process: work_process
    ).tap do |competency|
      competency.update!(title: competency_data[:sort_order])
    end
  end
end
