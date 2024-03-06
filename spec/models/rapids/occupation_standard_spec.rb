require "rails_helper"

RSpec.describe RAPIDS::OccupationStandard, type: :model do
  describe ".initialize_from_response" do
    it "returns occupation standard with correct data" do
      occupation_standard_response = create(:rapids_api_occupation_standard)

      occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

      expect(occupation_standard.title).to eq occupation_standard_response["occupationTitle"]
      expect(occupation_standard.onet_code).to eq occupation_standard_response["onetSocCode"]
      expect(occupation_standard.rapids_code).to eq occupation_standard_response["rapidsCode"]
    end

    context "when occupation title has a different encoding" do
      it "returns correct UTF-8 representation" do
        occupation_standard_response = create(
          :rapids_api_occupation_standard,
          title: "ALARM �OPERATOR (Gov Serv) (0870HYV1) Hybrid"
        )

        occupation_standard = RAPIDS::OccupationStandard.initialize_from_response(occupation_standard_response)

        expect(occupation_standard.title).to eq "ALARM  OPERATOR (Gov Serv) (0870CBV1)"
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
          california = create(:state, name: "California", abbreviation: "CA")
          oa_registration_agency_for_california = create(:registration_agency, state: california, agency_type: "oa")
          _saa_registration_agency_for_california = create(:registration_agency, state: california, agency_type: "saa")

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
  end
end
