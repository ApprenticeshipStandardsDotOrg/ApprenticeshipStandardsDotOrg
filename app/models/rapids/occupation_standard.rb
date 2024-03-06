module RAPIDS
  class OccupationStandard
    OCC_TYPE_MAPPING = {
      "Time-Based" => :time,
      "Competency-Based" => :competency,
      "Hybrid" => :hybrid
    }

    class << self
      def initialize_from_response(response)
        ::OccupationStandard.new(
          title: fix_encoding(response["occupationTitle"]),
          onet_code: response["onetSocCode"],
          rapids_code: response["rapidsCode"],
          ojt_type: ojt_type(response["occType"]),
          registration_agency: find_registration_agency_by_sponsor_number(
            response["sponsorNumber"]
          )
        )
      end

      private

      def ojt_type(occ_type)
        OCC_TYPE_MAPPING[occ_type]
      end

      def find_registration_agency_by_sponsor_number(sponsor_number)
        registration_agency = nil

        if sponsor_number.present?
          parsed_sponsor_name = sponsor_number.match(/-?(?<state>[A-Z]{2})/)

          state_abbreviation = parsed_sponsor_name && parsed_sponsor_name[:state]

          state = State.find_by(
            abbreviation: state_abbreviation
          )

          if state
            registration_agency = state.registration_agencies.find_by(agency_type: "oa")
          end
        end

        registration_agency || RegistrationAgency.registration_agency_for_national_program
      end

      def fix_encoding(text)
        text.encode("UTF-8", "UTF-8", invalid: :replace, replace: "")
      end
    end
  end
end
