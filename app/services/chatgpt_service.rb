require "openai"

class ChatgptService
  OpenAI.configure do |config|
    config.access_token = ENV.fetch("CHATGPT_API_KEY")
  end

  def initialize
    @client = OpenAI::Client.new
  end

  def generate_text(prompt)
    response = @client.chat(
      parameters: {
          model: "gpt-3.5-turbo", 
          messages: [{ role: "user", content: prompt}], 
          temperature: 0.7,
      })

    response.dig("choices", 0, "message", "content")
  end
end