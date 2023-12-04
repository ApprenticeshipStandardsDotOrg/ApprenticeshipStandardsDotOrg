require "openai"

class ChatGptGenerateText
  attr_reader :prompt

  def initialize(prompt)
    @client = OpenAI::Client.new
    @prompt = prompt
  end

  def call
    response = @client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [{role: "user", content: prompt}],
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")
  end
end
