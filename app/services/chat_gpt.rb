require "openai"

class ChatGPT
  def initialize
    @client = OpenAI::Client.new
  end

  def chat(prompt)
    response = client.chat(
      parameters: {
        model: "gpt-4",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.7
      }
    )
 pp response.dig("choices", 0, "message", "content")
    response.dig("choices", 0, "message", "content")
  rescue Faraday::TooManyRequestsError => e
    on_error(e)
  end

  private

  attr_reader :client

  def on_error(exception)
    body = exception.response.fetch(:body).fetch("error")
    msg = "(#{body['code']}) #{body['message']}"
    raise OpenAIError, msg
  end

  class OpenAIError < StandardError; end
end
