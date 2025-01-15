require "openai"

class ChatGptGenerateText
  attr_reader :prompt

  def initialize(prompt)
    @client = OpenAI::Client.new
    @prompt = prompt
  end

  def call
    Rails.logger.info "Calling OpenAI with #{OpenAI.rough_token_count(prompt)} tokens"
    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [{role: "user", content: prompt}],
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")
  end
end
