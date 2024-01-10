class PdfReaderJob < ApplicationJob
  queue_as :default

  def perform(source_file_id)
    source_file = SourceFile.find(source_file_id)
    return unless source_file.pdf?
    io = URI.open(source_file.url)

    reader = PDF::Reader.new(io)
    text = reader.pages.map{|page| page.text}.to_s

    template = {
      "Title" => "",
      "Type" => "(Time based, Competency based, or Hybrid)"
    }

    occupation_array_prompt = "Create an array of the occupation(s) from the text. Return as a JSON array"
    occupations = ChatGptGenerateText.new("#{occupation_array_prompt} #{text}").call
    puts occupations

    JSON.parse(occupations).each do |occupation|
      prompt = "Please fill out the template based on the given information for this occupation: #{occupation}"
      puts "*" * 10
      puts occupation
      puts ChatGptGenerateText.new("#{prompt} information:#{text} template: #{template}").call
    end
  end
end
