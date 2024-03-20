require "rails_helper"

RSpec.describe ChatGPT do
  describe "#chat" do
    it "returns generated text" do
      mock_client
      service = described_class.new
      expect(service.chat("Hello")).to eq "Hello! How can I assist you today?"
    end

    def mock_client
      mock = instance_double "OpenAI::Client"
      allow(OpenAI::Client).to receive(:new).and_return mock

      mocked_response = {
        "id" => "chatcmpl1",
        "object" => "chat.completion",
        "created" => 1701713529,
        "model" => "gpt-4",
        "choices" => [{
          "index" => 0,
          "message" =>
            {"role" => "assistant", "content" => "Hello! How can I assist you today?"},
          "finish_reason" => "stop"
        }],
        "usage" => {
          "prompt_tokens" => 8,
          "completion_tokens" => 9,
          "total_tokens" => 17
        },
        "system_fingerprint" => nil
      }

      allow(mock)
        .to receive(:chat)
        .with(
          parameters: {
            model: "gpt-4",
            messages: [{role: "user", content: "Hello"}],
            temperature: 0.7
          }
        )
        .and_return mocked_response

      mock
    end
  end
end
