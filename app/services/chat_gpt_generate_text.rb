require "openai"

class ChatGptGenerateText
  attr_reader :prompt

  def initialize(prompt)
    @client = OpenAI::Client.new
    @prompt = prompt
  end

  def call
    begin
      attempts ||= 0
      response = @client.chat(
        parameters: {
          model: "gpt-4",
          messages: [{role: "user", content: prompt}],
          temperature: 0.7
        }
        )

        response.dig("choices", 0, "message", "content")
      rescue Faraday::TooManyRequestsError => e
        if attempts <= 5
          duration = e.response_headers['Retry-After'].to_i + 1
          puts "Duration: #{duration}"
          sleep duration
          retry
        end
      end
  end
end
