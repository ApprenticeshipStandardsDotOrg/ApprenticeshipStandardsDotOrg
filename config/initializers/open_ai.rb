require "openai"

OpenAI.configure do |config|
  config.access_token = ENV["CHATGPT_API_KEY"]
end
