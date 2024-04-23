require "openai"

class LLM
  def self.chat(...) = new.chat(...)

  def self.as_assistant(...) = new.as_assistant(...)

  delegate :assistants, :files, :threads, :messages, :runs, :run_steps, to: :llm

  def initialize
    @llm = OpenAI::Client.new
  end

  # Involves an LLM::Assistant to perform steps in a provided block
  # @return [Array<Hash>] Content received from remote LLM service
  # @raise [LLM::RateError] Remote service is rejecting request as exceeding their rate limits
  # @raise [LLM::InvalidRequestError] Remote service is unable to process request(s)
  # @raise [LLM::TimeoutError] Remote service is not timely in responding
  # @raise [LLM::Assistant::RunFailedError] when run cancelled, failed, or expired on remote service
  # @raise [LLM::Assistant::UnknownRunStatusError] when remote service responses with an unexpected status
  #
  # @example
  #   filepath = <some filepath as a string (e.g, Filepath#to_s result)>
  #   llm = LLM.new
  #   llm.as_assistant do |asst|
  #     asst.upload(filepath:, key: 'attachment')
  #     asst.post("What type of file is this?", file_keys['attachment'])
  #     asst.post("What's the longest word?", file_keys['attachment'])
  #     asst.post("How many planets are in our solar system?")
  #   end
  #     # => [
  #       { text: "This file is a PDF and its longest word is \"antidisestablishmentarianism\"." },
  #       { text: "This solar system has 8 planets." }
  #     ]
  # @note Hash response intended to be extensible for
  def as_assistant(&block)
    asst = LLM::Assistant.new(client: self)
    begin
      yield asst
    rescue Faraday::TooManyRequestsError => e
      raise RateError, error_message(e)
    rescue Faraday::BadRequestError => e
      raise InvalidRequestError, error_message(e)
    rescue Net::ReadTimeout => e
      raise TimeoutError
    ensure
      results = asst.await_results
      asst.destroy!
    end

    results
  end

  # Directly responds to a prompt in support of an interactive chat
  # @param prompt [String] Text of a request for the LLM to respond to
  # @return [String] Reply text from the LLM
  # @raise [LLM::RateError] Remote service is rejecting request as exceeding their rate limits
  # @raise [LLM::InvalidRequestError] Remote service is unable to process request(s)
  # @raise [LLM::TimeoutError] Remote service is not timely in responding
  #
  # @example
  #   llm = LLM.new
  #   llm.chat "How many planets are in our solar system?"
  #     # => "This solar system has 8 planets."
  def chat(prompt)
    response = llm.chat(
      parameters: {
        model: "gpt-4",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.1
      }
    )
    response.dig("choices", 0, "message", "content")
  rescue Faraday::TooManyRequestsError => e
    raise RateError, error_message(e)
  rescue Faraday::BadRequestError => e
    raise InvalidRequestError, error_message(e)
  rescue Net::ReadTimeout => e
    raise TimeoutError
  end

  # @params filepath [String] Path to file for upload
  # @params purpose [String] specifies the intended use for the file being uploaded
  def upload(filepath, purpose: "assistants")
    llm.files.upload(
      parameters: {
        file: filepath,
        purpose:
      }
    )
  end

  private

  attr_reader :llm

  def error_message(exception, engine = :anthropic)
    body = exception.response.fetch(:body).fetch("error")
    "(#{body['code']}) #{body['message']}"
  end

  class Error < StandardError; end
  class TimeoutError < LLM::Error; end
  class RateError < LLM::Error; end
  class InvalidRequestError < LLM::Error; end
end
