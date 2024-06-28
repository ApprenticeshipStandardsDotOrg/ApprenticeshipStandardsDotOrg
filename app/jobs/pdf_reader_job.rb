class PdfReaderJob < ApplicationJob
  queue_as :default

  def perform(import_id)
    pdf = Imports::Pdf.find(import_id)

    pdf.file.open do |io|
      reader = PDF::Reader.new(io)
      text = reader.pages.map { |page| page.text }.to_s

      template = '{ "Title": "", "Type": "(Time based, Competency based, or Hybrid)" }'

      occupation_array_prompt = "Create an array of the occupation(s) from the text. Return as a JSON array"
      occupations = ChatGptGenerateText.new("#{occupation_array_prompt} #{text}").call

      occupations_response = JSON.parse(occupations).map do |occupation|
        prompt = "Please fill out the template based on the given information for this occupation: #{occupation} and return as JSON array"
        response = ChatGptGenerateText.new("#{prompt} information:#{text} template: #{template}").call
        JSON.parse(response)
      end

      occupations_response.flatten
    end
  end
end
