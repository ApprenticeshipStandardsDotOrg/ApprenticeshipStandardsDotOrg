module RAPIDS
  class OccupationStandard
    OCC_TYPE_MAPPING = {
      "Time-Based" => :time,
      "Competency-Based" => :competency,
      "Hybrid" => :hybrid
    }

    class << self
      include Sanitizable

      def initialize_from_response(response)
        rapids_code = sanitize_rapids_code(response["rapidsCode"])
        onet_code = response["onetSocCode"]
        title = fix_encoding(response["occupationTitle"])
        ::OccupationStandard.new(
          title: title,
          onet_code: onet_code,
          rapids_code: rapids_code,
          ojt_type: ojt_type(response["occType"]),
          registration_agency: find_registration_agency_by_sponsor_number(
            response["sponsorNumber"]
          ),
          organization: find_or_create_organization_by_organization_name(response["sponsorName"]),
          occupation: find_occupation(rapids_code, onet_code),
          external_id: extract_wps_id(response["wpsDocument"]),
          registration_date: response["createdDt"]
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

      def find_or_create_organization_by_organization_name(organization_name)
        ::Organization.find_or_initialize_by(
          title: organization_name
        )
      end

      def find_occupation(rapids_code, onet_code)
        find_occupation_by_rapids_code(rapids_code) || find_occupation_by_onet_code(onet_code)
      end

      def find_occupation_by_rapids_code(rapids_code)
        Occupation.find_by(rapids_code: rapids_code)
      end

      def find_occupation_by_onet_code(onet_code)
        Occupation.includes(:onet).find_by(
          onet: {
            code: onet_code
          }
        )
      end

      def sanitize_rapids_code(rapids_code)
        return if rapids_code.blank?

        rapids_code.gsub(/[A-Za-z]+\z/, "").ljust(4, "0")
      end

      def extract_wps_id(wps_document_url)
        result = wps_document_url.match(/.*\/(?<wps_id>\d*)/)
        result && result[:wps_id]
      end
    end
  end
end
