class WorkProcessExtractorJob < ApplicationJob
  queue_as :default

  def perform(occupation_standard, competency_data)
    response = ChatGptGenerateText.new(prompt).call

    JSON.parse(response).each do |description, hour_bounds|
      WorkProcessExtraction.extract(
        occupation_standard:,
        competency_data:,
        description:,
        hour_bounds:
      )
    end
  end

  private

  def prompt
    "Could you identify the work processes and the hours spent in them in this document " \
    "in a json with name of the process as key and hours as an array with the values of " \
    "minimum and maximum hours? Use 'N/A' when there is no hour, and fill both values of " \
    "the array with the same number when there is only one value for hour. #{text}"
  end

  def text
    # TODO: this is bespoke and only for testing ATM
    # Seems like Nina had some particular file that made sense here
    filepath = Rails.root.join("tmp", "test3.pdf")
    reader = PDF::Reader.new(filepath)
    reader.pages[19..23]&.map(&:text)
  end
end
