require "rails_helper"

RSpec.describe ImportDataFromRAPIDSJob, type: :job do
  describe "#perform" do
    context "when receiving a competency-based standard" do
      it "creates the associated records" do
        stub_get_token!
        create_registration_agency_for("MI", agency_type: :oa)

        occupation_standard_response = create_list(
          :rapids_api_occupation_standard,
          1,
          :competency,
          with_detailed_work_activities: 3
        )
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
        }.to change(OccupationStandard, :count).by(1).and \
          change(WorkProcess, :count).by(3)

        occupation_standard = OccupationStandard.last

        expect(occupation_standard.ojt_type).to eq "competency"
        expect(occupation_standard.work_processes.count).to eq 3
      end
    end

    context "when receiving a time-based standard" do
      it "creates the associated records" do
        stub_get_token!
        create_registration_agency_for("MI", agency_type: :oa)

        occupation_standard_response = create_list(
          :rapids_api_occupation_standard,
          1,
          :time,
          with_detailed_work_activities: 2
        )
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
        }.to change(OccupationStandard, :count).by(1).and \
          change(WorkProcess, :count).by(2)

        occupation_standard = OccupationStandard.last

        expect(occupation_standard.ojt_type).to eq "time"
        expect(occupation_standard.work_processes.count).to eq 2
      end
    end

    context "when receiving a hybrid standard" do
      it "creates the associated records" do
        stub_get_token!
        create_registration_agency_for("MI", agency_type: :oa)

        occupation_standard_response = create_list(
          :rapids_api_occupation_standard,
          1,
          :hybrid,
          with_detailed_work_activities: 4
        )
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
        }.to change(OccupationStandard, :count).by(1).and \
          change(WorkProcess, :count).by(4)

        occupation_standard = OccupationStandard.last

        expect(occupation_standard.ojt_type).to eq "hybrid"
        expect(occupation_standard.work_processes.count).to eq 4
      end
    end

    context "pagination" do
      it "performs more than one call with correct arguments when records exceed batch size" do
        stub_get_token!
        create_registration_agency_for("MI", agency_type: :oa)
        stub_const("ImportDataFromRAPIDSJob::PER_PAGE_SIZE", 1)

        (first_occupation, second_occupation, third_occupation) = create_list(:rapids_api_occupation_standard, 3, :hybrid)

        first_rapids_response = create(:rapids_response, totalCount: 3, wps: [first_occupation])
        second_rapids_response = create(:rapids_response, totalCount: 3, wps: [second_occupation])
        third_rapids_response = create(:rapids_response, totalCount: 3, wps: [third_occupation])

        expect_any_instance_of(RAPIDS::API).to receive(:get).with("/sponsor/wps", {
          batchSize: 1,
          startIndex: 1
        }).and_return(
          OpenStruct.new(
            parsed: first_rapids_response
          )
        )

        expect_any_instance_of(RAPIDS::API).to receive(:get).with("/sponsor/wps", {
          batchSize: 1,
          startIndex: 2
        }).and_return(
          OpenStruct.new(
            parsed: second_rapids_response
          )
        )

        expect_any_instance_of(RAPIDS::API).to receive(:get).with("/sponsor/wps", {
          batchSize: 1,
          startIndex: 3
        }).and_return(
          OpenStruct.new(
            parsed: third_rapids_response
          )
        )

        expect {
          described_class.perform_now
        }.to change(OccupationStandard, :count).to eq 3
      end
    end

    context "invalid records" do
      it "saves the occupation standard discarding invalid work processes" do
        stub_get_token!
        create_registration_agency_for("MI", agency_type: :oa)

        invalid_detailed_work_activity = create_list(
          :rapids_api_detailed_work_activity_for_hybrid,
          1,
          title: ""
        )

        occupation_standard_response = create_list(
          :rapids_api_occupation_standard,
          1,
          :competency,
          dwas: invalid_detailed_work_activity
        )

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
        }.to change(OccupationStandard, :count).by(1).and \
          change(WorkProcess, :count).by(0)
      end
    end
  end
end

def stub_get_token!
  allow_any_instance_of(RAPIDS::API).to receive(:get_token!).and_return "xxx"
end

def create_registration_agency_for(state_abbreviation, agency_type:)
  state = create(:state, abbreviation: "MI")
  create(:registration_agency, state: state, agency_type: agency_type)
end

def stub_rapids_api_response(arguments, response)
  allow_any_instance_of(RAPIDS::API).to receive(:get).with("/sponsor/wps", arguments).and_return(
    OpenStruct.new(
      parsed: response
    )
  )
end
