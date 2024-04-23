require "rails_helper"

RSpec.describe RAPIDS::OccupationStandard, type: :model do
  describe ".initialize_from_response" do
    it "returns occupation standard with correct data" do
      occupation_standard_response = create(:rapids_api_occupation_standard)

      occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

      expect(occupation_standard.title).to eq occupation_standard_response["occupationTitle"]
      expect(occupation_standard.onet_code).to eq occupation_standard_response["onetSocCode"]
      expect(occupation_standard.rapids_code).to eq occupation_standard_response["rapidsCode"]
      expect(occupation_standard.metadata).to eq occupation_standard_response
    end

    context "when occupation title has a different encoding" do
      it "returns correct UTF-8 representation" do
        occupation_standard_response = create(
          :rapids_api_occupation_standard,
          occupationTitle: "\xA0ALARM OPERATOR (Gov Serv) (0870HYV1) Hybrid"
        )

        occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

        expect(occupation_standard.title).to eq "ALARM OPERATOR (Gov Serv) (0870HYV1) Hybrid"
        expect(occupation_standard.metadata["occupationTitle"]).to eq "ALARM OPERATOR (Gov Serv) (0870HYV1) Hybrid"
      end
    end

    context "ojt_type" do
      it "returns correct ojt type when occType is Hybrid" do
        occupation_standard_response = create(
          :rapids_api_occupation_standard,
          occType: "Hybrid"
        )

        occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

        expect(occupation_standard.ojt_type).to eq "hybrid"
      end

      it "returns correct ojt type when occType is Time-Based" do
        occupation_standard_response = create(
          :rapids_api_occupation_standard,
          occType: "Time-Based"
        )

        occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

        expect(occupation_standard.ojt_type).to eq "time"
      end

      it "returns correct ojt type when occType is Competency-Based" do
        occupation_standard_response = create(
          :rapids_api_occupation_standard,
          occType: "Competency-Based"
        )

        occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

        expect(occupation_standard.ojt_type).to eq "competency"
      end
    end

    context "registration_agency" do
      context "when sponsorNumber is not present" do
        it "sets registration agency as national standard" do
          registration_agency_for_national_standard = create(:registration_agency, :for_national_program)

          occupation_standard_response = create(
            :rapids_api_occupation_standard,
            sponsorNumber: ""
          )

          occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

          expect(occupation_standard.registration_agency).to eq registration_agency_for_national_standard
        end
      end

      context "when sponsorNumber contains the name of the state" do
        it "sets OA registration agency for that specific state" do
          oa_registration_agency_for_california = create(:registration_agency, for_state_abbreviation: "CA", agency_type: "oa")
          _saa_registration_agency_for_california = create(:registration_agency, for_state_abbreviation: "CA", agency_type: "saa")

          occupation_standard_response = create(
            :rapids_api_occupation_standard,
            sponsorNumber: "2019-CA-73347"
          )

          occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

          expect(occupation_standard.registration_agency).to eq oa_registration_agency_for_california
        end
      end

      context "when sponsorNumber contains an invalid state abbreviation" do
        it "sets registration agency for national standard" do
          registration_agency_for_national_standard = create(:registration_agency, :for_national_program)

          occupation_standard_response = create(
            :rapids_api_occupation_standard,
            sponsorNumber: "2019-ZA-73347"
          )

          occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

          expect(occupation_standard.registration_agency).to eq registration_agency_for_national_standard
        end
      end

      context "when sponsorNumber does not contain a state abbreviation" do
        it "sets registration agency for national standard" do
          registration_agency_for_national_standard = create(:registration_agency, :for_national_program)

          occupation_standard_response = create(
            :rapids_api_occupation_standard,
            sponsorNumber: "2019-73347"
          )

          occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

          expect(occupation_standard.registration_agency).to eq registration_agency_for_national_standard
        end
      end
    end

    context "rapids_code" do
      it "sanitizes rapids code" do
        occupation_standard_response = create(
          :rapids_api_occupation_standard,
          rapidsCode: "0870CB"
        )

        occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

        expect(occupation_standard.rapids_code).to eq "0870"
      end
    end

    context "occupation" do
      it "sets occupation using rapids code if present" do
        occupation = create(:occupation, rapids_code: "0221")

        occupation_standard_response = create(
          :rapids_api_occupation_standard,
          rapidsCode: "0221"
        )

        occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

        expect(occupation_standard.occupation).to eq occupation
      end

      it "sets occupation using sanitized rapids code if present" do
        occupation = create(:occupation, rapids_code: "0221")

        occupation_standard_response = create(
          :rapids_api_occupation_standard,
          rapidsCode: "0221CB"
        )

        occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

        expect(occupation_standard.occupation).to eq occupation
      end

      it "sets occupation as nil if rapids is not present" do
        occupation_standard_response = create(
          :rapids_api_occupation_standard,
          rapidsCode: ""
        )

        occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

        expect(occupation_standard.occupation).to be_nil
      end

      it "sets occupation as nil if occupation does not exist" do
        occupation_standard_response = create(
          :rapids_api_occupation_standard,
          rapidsCode: "0221CB"
        )

        occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

        expect(occupation_standard.occupation).to be_nil
      end

      context "when occupation by rapids code is not found" do
        it "sets occupation using onet code" do
          onet = create(:onet, code: "47-2121.00")
          occupation = create(:occupation, rapids_code: nil, onet: onet)

          occupation_standard_response = create(
            :rapids_api_occupation_standard,
            onetSocCode: onet.code
          )

          occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

          expect(occupation_standard.occupation).to eq occupation
        end

        it "sets occupation as nil if onet not present" do
          occupation_standard_response = create(
            :rapids_api_occupation_standard,
            onetSocCode: "47-2121.00"
          )

          occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

          expect(occupation_standard.occupation).to be_nil
        end
      end

      it "extracts external id from wpsDocument value" do
        occupation_standard_response = build(
          :rapids_api_occupation_standard,
          wpsDocument: "https://entbpmpstg.dol.gov/suite/webapi/rapids/data-sharing/documents/wps/111111"
        )

        occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

        expect(occupation_standard.external_id).to eq "111111"
      end
    end

    context "organization" do
      it "creates corresponding organization if it does not exist already" do
        create(:registration_agency, :for_national_program)

        occupation_standard_response = create(
          :rapids_api_occupation_standard,
          :hybrid,
          sponsorName: "thoughtbot",
          sponsorNumber: "2019-73347"
        )

        occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

        organization = occupation_standard.organization
        expect(organization.title).to eq "thoughtbot"

        expect {
          occupation_standard.save!
        }.to change(OccupationStandard, :count).by(1).and \
          change(Organization, :count).by(1)
      end

      it "uses current organization if already created" do
        create(:registration_agency, :for_national_program)
        create(:organization, title: "thoughtbot")

        occupation_standard_response = create(
          :rapids_api_occupation_standard,
          :hybrid,
          sponsorName: "thoughtbot",
          sponsorNumber: "2019-73347"
        )

        occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

        organization = occupation_standard.organization
        expect(organization.title).to eq "thoughtbot"

        occupation_standard.save!

        expect(Organization.count).to eq 1
      end
    end
  end
end
