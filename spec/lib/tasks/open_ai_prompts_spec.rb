require "rails_helper"

Rails.application.load_tasks unless Rake::Task.task_defined?("open_ai_prompts:create_default")

RSpec.describe "open_ai_prompts:create_default" do
  after do
    Rake::Task["open_ai_prompts:create_default"].reenable
  end

  it "creates a code-defined prompt as the new default" do
    previous_default = create(:open_ai_prompt, default: true)
    existing_prompt = create(:open_ai_prompt)

    expect {
      Rake::Task["open_ai_prompts:create_default"].invoke
    }.to change(OpenAIPrompt, :count).by(1)

    default_prompt = OpenAIPrompt.default

    expect(default_prompt.name).to eq(OpenAIPrompt::DEFAULT_NAME)
    expect(default_prompt.prompt).to eq(OpenAIPrompt::DEFAULT_PROMPT)
    expect(previous_default.reload).not_to be_default
    expect(existing_prompt.reload).to be_present
  end
end
