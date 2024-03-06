require "rails_helper"

RSpec.describe RAPIDS::API do
  describe ".call" do
    it "fetches auth token from API" do
      expect_any_instance_of(RAPIDS::API).to receive(:get_token!).and_return "xxx"

      described_class.call
    end
  end

  describe "#work_processes" do
    context "without params" do
      it "calls the correct end-point" do
        stub_get_token!

        result = described_class.call

        expect(result).to receive(:get).with("/wps", {})
        result.work_processes
      end
    end

    context "when params provided" do
      it "calls the correct end-point" do
        stub_get_token!

        result = described_class.call
        expect(result).to receive(:get).with("/wps", {batchSize: 50, startIndex: 10})
        result.work_processes(batchSize: 50, startIndex: 10)
      end
    end
  end
end

def stub_get_token!
  allow_any_instance_of(RAPIDS::API).to receive(:get_token!).and_return "xxx"
end
