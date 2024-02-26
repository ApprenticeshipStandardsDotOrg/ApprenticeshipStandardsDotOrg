class WorkProcessExtractorJob < ApplicationJob
  queue_as :default

  def perform
    response = ChatGptGenerateText.new(prompt).call
    puts response
  end

private

  def prompt
    "Could you identify the work processes and the hours spent in them in this document " \
    "in a json with name of the process as key and hours as the value? Use 'N/A' when there " \
    "is no hour. #{text}"
  end

  def text
    filepath = Rails.root.join("tmp", "test4.pdf")
    reader = PDF::Reader.new(filepath)

    reader.pages.map(&:text)
  end
end
