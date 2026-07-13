namespace :after_party do
  desc "Deployment task: create_default_open_ai_prompt"
  task create_default_open_ai_prompt: :environment do
    puts "Running deploy task 'create_default_open_ai_prompt'"

    OpenAIPrompt.create_default!
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
