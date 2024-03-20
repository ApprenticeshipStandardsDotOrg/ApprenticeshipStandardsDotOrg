class PdfReaderJob < ApplicationJob
  queue_as :default

  def perform(source_file_id)
    source_file = SourceFile.find(source_file_id)
    return unless source_file.pdf?
    io = URI.parse(source_file.url).open
    text = PdfFile.text(io)
    template = '{ "Title": "", "Type": "(Time based, Competency based, or Hybrid)" }'

    occupation_array_prompt = "Create an array of the occupation(s) from the text. Return as a JSON array"
    occupations = LLM.new.chat("#{occupation_array_prompt} #{text}")

    occupations_response = JSON.parse(occupations).map do |occupation|
      prompt = "Please fill out the template based on the given information for this occupation: #{occupation} and return as JSON array"
      response = LLM.new.chat("#{prompt} information:#{text} template: #{template}")
      JSON.parse(response)
    end

    occupations_response.flatten
  end
end
