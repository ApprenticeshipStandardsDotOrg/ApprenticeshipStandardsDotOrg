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
        model: "gpt-4",
        messages: [{role: "user", content: prompt}],
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")
  rescue Faraday::ResourceNotFound => e
    on_error(e)
  end

  private

  def on_error(err)
    error_hash = err.response.dig(:body, "error")
    case error_hash["type"]
    when "invalid_request_error"
      raise InvalidRequestError.new(error_hash:)
    else
      raise UnknownError.new(error_hash:)
    end
  end

  class ChatGptError < StandardError
    attr_reader :type, :param, :code

    def initialize(error_hash:)
      message = error_hash["message"]
      @type = error_hash["type"]
      @param = error_hash["param"]
      @code = error_hash["code"]
      super("#{message} (code: #{@code}; param: #{param || '-nil-'})")
    end
  end
  class InvalidRequestError < ChatGptError; end
  class UnknownError < ChatGptError; end
end
