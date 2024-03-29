require "rails_helper"

RSpec.describe OnetWebService do
  describe "#call" do
    it "updates related_job_titles field on onet record" do
      stub_responses
      onet = create(:onet, code: "17-2051.00", related_job_titles: [])
      service = described_class.new(onet)
      service.call

      expect(onet.related_job_titles).to contain_exactly("City Engineer", "Civil Engineer")
    end

    it "sets related_job_titles to empty if field is empty" do
      stub_responses_empty_field
      onet = create(:onet, code: "17-2051.00", related_job_titles: ["Engineer"])
      service = described_class.new(onet)
      service.call

      expect(onet.related_job_titles).to be_empty
    end

    it "does not update related_job_titles if field is missing" do
      stub_responses_missing_field
      onet = create(:onet, code: "17-2051.00", related_job_titles: ["Engineer"])
      service = described_class.new(onet)
      service.call

      expect(onet.related_job_titles).to eq ["Engineer"]
    end
  end

  def stub_responses
    Dotenv.modify("ONET_WEB_SERVICES_USERNAME" => "username", "ONET_WEB_SERVICES_PASSWORD" => "secret") do
      json_file = file_fixture("onet_web_service_response.json")
      stub_request(:get, /services.onetcenter.org/)
        .to_return(
          {status: 200, body: json_file.read, headers: {}}
        )
    end
  end

  def stub_responses_empty_field
    Dotenv.modify("ONET_WEB_SERVICES_USERNAME" => "username", "ONET_WEB_SERVICES_PASSWORD" => "secret") do
      json_file = file_fixture("onet_web_service_response_empty_field.json")
      stub_request(:get, /services.onetcenter.org/)
        .to_return(
          {status: 200, body: json_file.read, headers: {}}
        )
    end
  end

  def stub_responses_missing_field
    Dotenv.modify("ONET_WEB_SERVICES_USERNAME" => "username", "ONET_WEB_SERVICES_PASSWORD" => "secret") do
      json_file = file_fixture("onet_web_service_response_missing_field.json")
      stub_request(:get, /services.onetcenter.org/)
        .to_return(
          {status: 200, body: json_file.read, headers: {}}
        )
    end
  end
end
