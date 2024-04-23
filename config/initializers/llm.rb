# require "boxcars"
# Boxcar.configuration.default_engine = :openai  # or you can specify another engine like :anthropic or :gpt4all

# To use for anthropic LLM (instead of OpenAI)
# Boxcars.configuration do |config|
#   config.default_engine = :anthropic
#   config.anthropic_api_key = ENV.fetch("LLM_CLAUDE_API_KEY")
# end
