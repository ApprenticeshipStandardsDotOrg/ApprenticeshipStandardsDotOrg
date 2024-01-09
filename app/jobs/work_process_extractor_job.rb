class WorkProcessExtractorJob < ApplicationJob
  queue_as :default

  def perform
    file = "/Users/nina/Documents/ApprenticeshipStandardsDotOrg/tmp/test4.pdf"
    reader = PDF::Reader.new(file)
    text = reader.pages.map { |page| page.text }

    prompt = "Could you identify the work processes and the hours spent in them in this document in a json with name of the process as key and hours as the value? Use 'N/A' when there is no hour. #{text}"
    response = ChatGptGenerateText.new(prompt).call
    puts response
  end
end
