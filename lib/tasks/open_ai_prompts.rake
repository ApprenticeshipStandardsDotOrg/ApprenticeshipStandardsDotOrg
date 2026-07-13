namespace :open_ai_prompts do
  desc "Create the code-defined OpenAI prompt and set it as the default"
  task create_default: :environment do
    prompt = OpenAIPrompt.create_default!
    puts "Created default OpenAI prompt: #{prompt.name} (#{prompt.id})"
  end
end
