require "openai"

class ChatGptGenerateText
  attr_reader :prompt

  def initialize(prompt, model: ENV.fetch("AI_CONVERSION_MODEL", "gpt-4o-mini"), reasoning_effort: ENV["AI_CONVERSION_REASONING_EFFORT"], json: ENV["AI_CONVERSION_JSON"] == "true")
    @client = model.start_with?("gpt-5.4") ? OpenAI::Client.new(request_timeout: 600) : OpenAI::Client.new
    @prompt = prompt
    @model = model
    @reasoning_effort = reasoning_effort
    @json = json
  end

  def call
    Rails.logger.info "Calling OpenAI #{@model} with #{OpenAI.rough_token_count(prompt)} tokens"
    parameters = {
      model: @model,
      messages: [{role: "user", content: prompt}]
    }
    parameters[:temperature] = 0 if @reasoning_effort.nil? || @reasoning_effort == "none"
    parameters[:reasoning_effort] = @reasoning_effort if @reasoning_effort.present?
    parameters[:response_format] = {type: "json_object"} if @json
    response = @client.chat(
      parameters: parameters
    )

    response.dig("choices", 0, "message", "content")
  end
end
