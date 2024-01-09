class PdfReaderJob < ApplicationJob
  queue_as :default

  def perform
    io = URI.open("https://www.dir.ca.gov/das/standards/5215_SacRT_Standards.pdf")

    reader = PDF::Reader.new(io)
    text = reader.pages[4..12].map { |page| page.text }

    ## Chatgpt cannot handle full_text at the moment because it is over the character limit
    # full_text = reader.pages.map{|page| page.text}

    template = {
      "state" => "(abbreviated)",
      "OA or SAA" => "(OA or SAA)",
      "Sponsor Name" => "",
      "Occupation Title" => "",
      "Existing Title" => "",
      "Type" => "(Time based, Competency based, or Hybrid)",
      "ONET code" => "",
      "RAPIDS code" => "",
      "probationary period months" => "",
      "apprenticeship_to_journeyworker_ratio" => "",
      "ojt_hours_min" => "",
      "ojt_hours_max" => "",
      "rsi_hours_min" => "(related instruction hours)",
      "rsi_hours_max" => "",
      "registration_date" => "",
      "latest_registration_update" => ""
    }

    occupation_array_prompt = "Please return an array with the names of the occupations listed in the text"
    occupations = ChatGptGenerateText.new("#{occupation_array_prompt} #{text}").call
    puts occupations

    JSON.parse(occupations).each do |occupation|
      prompt = "Please fill out the template based on the given information for this occupation: #{occupation}"
      puts "*" * 10
      puts occupation
      puts ChatGptGenerateText.new("#{prompt} #{template} #{text}").call
    end
  end
end
