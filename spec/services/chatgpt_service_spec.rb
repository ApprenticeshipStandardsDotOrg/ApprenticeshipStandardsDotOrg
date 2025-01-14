require "rails_helper"

RSpec.describe ChatGptGenerateText do
  describe "#call" do
    it "returns generated text" do
      client_mock = instance_double "OpenAI::Client"
      allow(OpenAI::Client).to receive(:new).and_return client_mock
      expected_resp = {
        "id" => "chatcmpl1",
        "object" => "chat.completion",
        "created" => 1701713529,
        "model" => "gpt-4o-mini",
        "choices" =>
          [{"index" => 0,
            "message" =>
            {"role" => "assistant", "content" => "Hello! How can I assist you today?"},
            "finish_reason" => "stop"}],
        "usage" => {"prompt_tokens" => 8, "completion_tokens" => 9, "total_tokens" => 17},
        "system_fingerprint" => nil
      }
      allow(client_mock).to receive(:chat).with(
        parameters: {
          model: "gpt-4o-mini",
          messages: [{role: "user", content: "Hello"}],
          temperature: 0.7
        }
      ).and_return expected_resp

      service = described_class.new("Hello")
      expect(service.call).to eq "Hello! How can I assist you today?"
    end
  end
end
