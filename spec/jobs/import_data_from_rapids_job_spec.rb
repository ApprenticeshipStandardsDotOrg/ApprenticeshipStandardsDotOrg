require "rails_helper"

RSpec.describe ImportDataFromRAPIDSJob, type: :job do
  describe "#perform" do
    context "when receiving a competency-based standard" do
      it "creates the associated records" do
        stub_get_token!

        mi = create(:state, abbreviation: "MI")
        create(:registration_agency, state: mi, agency_type: :oa)

        occupation_standard_response = create_list(:rapids_api_occupation_standard, 1, :competency)
        rapids_response = create(:rapids_response, totalCount: 1, wps: occupation_standard_response)

        stub_rapids_api_response(
          {
            batchSize: ImportDataFromRAPIDSJob::PER_PAGE_SIZE,
            startIndex: 1
          },
          rapids_response
        )
        expect {
          described_class.perform_now
        }.to change(OccupationStandard, :count).to eq 1

        occupation_standard = OccupationStandard.last

        expect(occupation_standard.ojt_type).to eq "competency"
      end
    end

    context "when receiving a time-based standard" do
      it "creates the associated records" do
        stub_get_token!

        mi = create(:state, abbreviation: "MI")
        create(:registration_agency, state: mi, agency_type: :oa)

        occupation_standard_response = create_list(:rapids_api_occupation_standard, 1, :time)
        rapids_response = create(:rapids_response, totalCount: 1, wps: occupation_standard_response)

        stub_rapids_api_response(
          {
            batchSize: ImportDataFromRAPIDSJob::PER_PAGE_SIZE,
            startIndex: 1
          },
          rapids_response
        )
        expect {
          described_class.perform_now
        }.to change(OccupationStandard, :count).to eq 1

        occupation_standard = OccupationStandard.last

        expect(occupation_standard.ojt_type).to eq "time"
      end
    end

    context "when receiving a hybrid standard" do
      it "creates the associated records" do
        stub_get_token!

        mi = create(:state, abbreviation: "MI")
        create(:registration_agency, state: mi, agency_type: :oa)

        occupation_standard_response = create_list(:rapids_api_occupation_standard, 1, :hybrid)
        rapids_response = create(:rapids_response, totalCount: 1, wps: occupation_standard_response)

        stub_rapids_api_response(
          {
            batchSize: ImportDataFromRAPIDSJob::PER_PAGE_SIZE,
            startIndex: 1
          },
          rapids_response
        )
        expect {
          described_class.perform_now
        }.to change(OccupationStandard, :count).to eq 1

        occupation_standard = OccupationStandard.last

        expect(occupation_standard.ojt_type).to eq "hybrid"
      end
    end
  end
end

def stub_get_token!
  allow_any_instance_of(RAPIDS::API).to receive(:get_token!).and_return "xxx"
end

def stub_rapids_api_response(arguments, response)
  allow_any_instance_of(RAPIDS::API).to receive(:get).with("/wps", arguments).and_return(
    OpenStruct.new(
      parsed: response
    )
  )
end
