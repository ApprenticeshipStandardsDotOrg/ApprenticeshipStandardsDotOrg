require "rails_helper"

RSpec.describe GenerateTrainingData do
  describe "#call" do
    it "returns training data based on the import" do
      client_mock = instance_double "OpenAI::Client"
      allow(OpenAI::Client).to receive(:new).and_return client_mock

      expected_result = "\n {\n\"title\": \"Proper/safe use of tools, materials, and equipment\",\n}\n"

      expected_resp = {
        "id" => "chatcmpl-A",
        "object" => "chat.completion",
        "created" => 1_726_499_655,
        "model" => "gpt-4-0613",
        "choices" =>
          [{
            "index" => 0,
            "message" =>
              {
                "role" => "assistant",
                "content" => expected_result,
                "refusal" => nil
              },
            "logprobs" => nil,
            "finish_reason" => "stop"
          }],
        "usage" =>
          {
            "prompt_tokens" => 1902,
            "completion_tokens" => 1019,
            "total_tokens" => 2921,
            "completion_tokens_details" => {"reasoning_tokens" => 0}
          },
        "system_fingerprint" => nil
      }

      allow(client_mock).to receive(:chat).and_return(expected_resp)

      service = GenerateTrainingData.new(pdf_text)
      expect(service.call).to eq(expected_result)
    end
  end
end
