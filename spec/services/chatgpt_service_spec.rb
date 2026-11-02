require "rails_helper"

RSpec.describe ChatGptGenerateText do
  describe "#call" do
    it "supports a reasoning model with enforced JSON without unsupported temperature settings" do
      client = instance_double(OpenAI::Client)
      allow(OpenAI::Client).to receive(:new).with(request_timeout: 600).and_return(client)
      expect(client).to receive(:chat).with(parameters: {
        model: "gpt-5.4",
        messages: [{role: "user", content: "Extract JSON"}],
        reasoning_effort: "low",
        response_format: {type: "json_object"}
      }).and_return({"choices" => [{"message" => {"content" => '{"occupations":[]}'}}]})

      result = described_class.new("Extract JSON", model: "gpt-5.4", reasoning_effort: "low", json: true).call

      expect(result).to eq '{"occupations":[]}'
    end

    it "uses temperature zero with reasoning disabled" do
      client = instance_double(OpenAI::Client)
      allow(OpenAI::Client).to receive(:new).with(request_timeout: 600).and_return(client)
      expect(client).to receive(:chat).with(parameters: {
        model: "gpt-5.4-mini", messages: [{role: "user", content: "Extract JSON"}],
        reasoning_effort: "none", temperature: 0
      }).and_return({"choices" => [{"message" => {"content" => "{}"}}]})

      expect(described_class.new("Extract JSON", model: "gpt-5.4-mini", reasoning_effort: "none", json: false).call).to eq "{}"
    end

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
          temperature: 0
        }
      ).and_return expected_resp

      service = described_class.new("Hello")
      expect(service.call).to eq "Hello! How can I assist you today?"
    end
  end
end
