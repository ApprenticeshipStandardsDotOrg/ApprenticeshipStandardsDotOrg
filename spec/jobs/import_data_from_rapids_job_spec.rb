require "rails_helper"

RSpec.describe ImportDataFromRAPIDSJob, type: :job do
  describe "#perform" do
    context "when receiving a competency-based standard" do
      it "creates the associated records" do
        stub_get_token!
        create(:registration_agency, for_state_abbreviation: "MI", agency_type: :oa)

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
          change(WorkProcess, :count).by(3).and \
            change(Competency, :count).by(3)

        occupation_standard = OccupationStandard.last

        expect(occupation_standard.ojt_type).to eq "competency"
        expect(occupation_standard.work_processes.count).to eq 3
      end
    end

    context "when receiving a time-based standard" do
      it "creates the associated records" do
        stub_get_token!
        create(:registration_agency, for_state_abbreviation: "MI", agency_type: :oa)

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
          change(WorkProcess, :count).by(2).and \
            change(Competency, :count).by(0)

        occupation_standard = OccupationStandard.last

        expect(occupation_standard.ojt_type).to eq "time"
        expect(occupation_standard.work_processes.count).to eq 2
      end
    end

    context "when receiving a hybrid standard" do
      it "creates the associated records" do
        stub_get_token!
        create(:registration_agency, for_state_abbreviation: "MI", agency_type: :oa)

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
          change(WorkProcess, :count).by(4).and \
            change(Competency, :count).by(4)

        occupation_standard = OccupationStandard.last

        expect(occupation_standard.ojt_type).to eq "hybrid"
        expect(occupation_standard.work_processes.count).to eq 4
      end
    end

    context "when receiving an existing standard" do
      it "does not create a duplicated record" do
        stub_get_token!
        create(:registration_agency, for_state_abbreviation: "MI", agency_type: :oa)

        occupation_standard_response = create_pair(
          :rapids_api_occupation_standard,
          :hybrid,
          occupationTitle: "\xA0Occupation 1",
          sponsorName: "thoughtbot",
          with_detailed_work_activities: 1
        )
        rapids_response = create(:rapids_response, totalCount: 2, wps: occupation_standard_response)

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
          change(WorkProcess, :count).by(1)
      end
    end

    context "retries" do
      it "performs a second attempt to fetch API when token expires" do
        stub_get_token!
        create(:registration_agency, for_state_abbreviation: "MI", agency_type: :oa)
        stub_const("ImportDataFromRAPIDSJob::PER_PAGE_SIZE", 1)

        (first_occupation, second_occupation) = create_list(:rapids_api_occupation_standard, 2, :hybrid)

        first_rapids_response = create(:rapids_response, totalCount: 2, wps: [first_occupation])
        second_rapids_response = create(:rapids_response, totalCount: 2, wps: [second_occupation])

        expect_any_instance_of(RAPIDS::API).to receive(:get).once.with("/sponsor/wps", {
          batchSize: 1,
          startIndex: 1
        }).and_raise(
          OAuth2::Error, "invalid oauth token"
        )

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

        expect {
          described_class.perform_now
        }.to change(OccupationStandard, :count).to eq 2
      end
    end

    context "pagination" do
      it "performs more than one call with correct arguments when records exceed batch size" do
        stub_get_token!
        create(:registration_agency, for_state_abbreviation: "MI", agency_type: :oa)
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
        create(:registration_agency, for_state_abbreviation: "MI", agency_type: :oa)

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

    context "wps document" do
      context "when document is mark as not uploaded" do
        it "does not attach a document" do
          stub_get_token!
          create(:registration_agency, for_state_abbreviation: "MI", agency_type: :oa)

          occupation_standard_response = create_list(
            :rapids_api_occupation_standard,
            1,
            :competency,
            isWPSUploaded: false
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
          }.to change(OccupationStandard, :count).by(1)

          occupation_standard = OccupationStandard.last

          expect(occupation_standard.redacted_document).to_not be_attached
        end
      end

      context "when document is mark as uploaded" do
        context "when response has a document" do
          it "attaches the document" do
            stub_get_token!
            create(:registration_agency, for_state_abbreviation: "MI", agency_type: :oa)

            occupation_standard_response = create_list(
              :rapids_api_occupation_standard,
              1,
              :competency,
              :with_wps_document,
              wpsDocument: "https://entbpmpstg.dol.gov/suite/webapi/rapids/data-sharing/documents/wps/123456"
            )
            rapids_response = create(:rapids_response, totalCount: 1, wps: occupation_standard_response)

            stub_rapids_api_response(
              {
                batchSize: ImportDataFromRAPIDSJob::PER_PAGE_SIZE,
                startIndex: 1
              },
              rapids_response
            )

            document = File.read(Rails.root.join(
              "spec", "fixtures", "files", "document.docx"
            ))

            stub_documents_response("123456", document)

            expect {
              described_class.perform_now
            }.to change(OccupationStandard, :count).by(1)

            occupation_standard = OccupationStandard.last

            expect(occupation_standard.redacted_document).to be_attached
          end
        end

        context "when response does not have a document" do
          it "skips document attachment" do
            stub_get_token!
            create(:registration_agency, for_state_abbreviation: "MI", agency_type: :oa)

            occupation_standard_response = create_list(
              :rapids_api_occupation_standard,
              1,
              :competency,
              :with_wps_document,
              wpsDocument: "https://entbpmpstg.dol.gov/suite/webapi/rapids/data-sharing/documents/wps/123456"
            )
            rapids_response = create(:rapids_response, totalCount: 1, wps: occupation_standard_response)

            stub_rapids_api_response(
              {
                batchSize: ImportDataFromRAPIDSJob::PER_PAGE_SIZE,
                startIndex: 1
              },
              rapids_response
            )

            stub_documents_response("123456", nil)

            expect {
              described_class.perform_now
            }.to change(OccupationStandard, :count).by(1)

            occupation_standard = OccupationStandard.last

            expect(occupation_standard.redacted_document).to_not be_attached
          end
        end
      end
    end
  end
end

def stub_get_token!
  allow_any_instance_of(RAPIDS::API).to receive(:get_token!).and_return "xxx"
end

def stub_rapids_api_response(arguments, response)
  allow_any_instance_of(RAPIDS::API).to receive(:get).with("/sponsor/wps", arguments).and_return(
    OpenStruct.new(
      parsed: response
    )
  )
end

def stub_documents_response(wps_id, document)
  allow_any_instance_of(RAPIDS::API).to receive(:post).with("/documents/wps/#{wps_id}").and_return(
    OpenStruct.new(
      body: document
    )
  )
end
