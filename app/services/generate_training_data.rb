require "openai"

class GenerateTrainingData
  def initialize(import_id)
    @client = OpenAI::Client.new
    @import_id = import_id
  end

  def call
    response = @client.chat(
      parameters: {
        model: "gpt-4",
        messages: [{role: "user", content: prompt}],
        temperature: 0.2
      }
    )

    response.dig("choices", 0, "message", "content")
  rescue => e
    puts ("Error: #{e.message}")
  end

  private

  def extract_text
    text = PdfToText.new(@import_id).call
    text.gsub('\n', ' ').gsub(/\s+/, ' ').strip
  end

  def base_prompt
    "Get the work processes from the following text in JSON format. JSON output needs the following fields:\
      title: title of the work process.
      description: description for the work process.
      defaultHours: amount of hours. It is optional. If value not found, return null.
      minimumHours: the minimum amount of hours required. If value not found, return null.
      maximumHours: the maximum amount of hours required. If value not found, return null.
      competencies: It is an array of text with each competency representing a line.
      Each competency has the following fields:
      title: title of the work process.
      Return only the output in JSON format without any block or markdown.

      The input text is:\n\n"
  end

  def prompt
    "#{base_prompt} #{extract_text}"
  end
end