require "rails_helper"

RSpec.describe OpenAIPrompt, type: :model do
  describe ".default" do
    it "returns the prompt explicitly marked as default" do
      create(:open_ai_prompt, name: "Older prompt")
      default_prompt = create(:open_ai_prompt, name: "Default prompt", default: true)

      expect(described_class.default).to eq(default_prompt)
    end
  end

  describe ".create_default!" do
    it "creates a new default prompt and preserves existing prompts" do
      previous_default = create(:open_ai_prompt, default: true)
      existing_prompt = create(:open_ai_prompt)

      new_default = described_class.create_default!(
        name: "Code prompt",
        prompt: "Prompt from code"
      )

      expect(new_default).to be_default
      expect(new_default.name).to eq("Code prompt")
      expect(new_default.prompt).to eq("Prompt from code")
      expect(previous_default.reload).not_to be_default
      expect(existing_prompt.reload).to be_present
    end
  end

  describe "#default" do
    it "clears the previous default when another prompt is saved as default" do
      previous_default = create(:open_ai_prompt, default: true)
      new_default = create(:open_ai_prompt)

      new_default.update!(default: true)

      expect(new_default.reload).to be_default
      expect(previous_default.reload).not_to be_default
    end
  end
end
