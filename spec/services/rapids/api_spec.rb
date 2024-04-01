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

        expect(result).to receive(:get).with("/sponsor/wps", {})
        result.work_processes
      end
    end

    context "when params provided" do
      it "calls the correct end-point" do
        stub_get_token!

        result = described_class.call
        expect(result).to receive(:get).with("/sponsor/wps", {batchSize: 50, startIndex: 10})
        result.work_processes(batchSize: 50, startIndex: 10)
      end
    end
  end

  describe "#documents" do
    context "when standards has document available" do
      it "calls the correct end-point" do
        stub_get_token!
        wps_id = 123456

        result = described_class.call
        expect(result).to receive(:post).with("/documents/wps/#{wps_id}")
        result.documents(wps_id: wps_id)
      end
    end

    context "when standard does not have associated document" do
      it "returns nil" do
        stub_get_token!
        wps_id = 500

        result = described_class.call
        allow(result).to receive(:post).with("/documents/wps/#{wps_id}").and_raise(OAuth2::Error, "internal server error")

        document = result.documents(wps_id: wps_id)
        expect(document).to be_nil
      end
    end
  end
end

def stub_get_token!
  allow_any_instance_of(RAPIDS::API).to receive(:get_token!).and_return "xxx"
end
