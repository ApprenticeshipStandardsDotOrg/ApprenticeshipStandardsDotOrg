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
        "model" => "gpt-3.5-turbo-1106",
        "choices" =>
          [{"index" => 0,
            "message" =>
              {"role" => "assistant",
               "content" =>
                  "{\n  \"name\": \"John\",\n  \"age\": 25,\n  \"city\": \"New York\",\n  \"email\": \"john@example.com\"\n}"},
            "finish_reason" => "stop"}],
        "usage" => {"prompt_tokens" => 8, "completion_tokens" => 9, "total_tokens" => 17},
        "system_fingerprint" => nil
      }
      allow(client_mock).to receive(:chat).with(
        parameters: {
          model: "gpt-3.5-turbo-1106",
          response_format: {type: "json_object"},
          messages: [{role: "user", content: "Hello, please give me some JSON"}],
          temperature: 0.7
        }
      ).and_return expected_resp

      service = described_class.new("Hello, please give me some JSON")
      expect(service.call).to eq "{\n  \"name\": \"John\",\n  \"age\": 25,\n  \"city\": \"New York\",\n  \"email\": \"john@example.com\"\n}"
    end
  end
end
