class ExtractOccupationStandard
  attr_reader :data_import

  def initialize(data_import)
    @data_import = data_import
  end

  def call
    data_import.file.open do |file|
      xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
      sheet = xlsx.sheet(0)

      sheet.parse(headers: true).each_with_index do |row, index|
        next if index.zero?

        state = State.find_by(abbreviation: row["Registration State"])
        reg_agency = RegistrationAgency.find_by(state: state, agency_type: row["OA or SAA"].downcase.to_sym)
        organization = if (sponsor_name = row["Sponsor Name"])
                    Organization.find_or_create_by!(name: sponsor_name)
                  end

        rapids_code = if (match = row["RAPIDS Code"].match(/(.*)[A-Za-z]{2}\z/))
                        match.captures.first
                      end

        occupation_type = case row["Type"]
                          when /competency/i
                            :competency
                          when /time/i
                            :time
                          when /hybrid/i
                            :hybrid
                          end

        occupation = Occupation.find_by(rapids_code: rapids_code)
        occupation ||= begin
                         onet_code = OnetCode.find_by(row["Onet Code"])
                         if onet_code
                           Occupation.find_by(onet_code: onet_code)
                         end
                       end

        OccupationStandard.create!(
          data_import: data_import,
          occupation: occupation,
          registration_agency: reg_agency,
          title: row["Occupation Title"],
          existing_title: row["Existing Title"],
          term_months: row["Term (in months)"],
          onet_code: row["Onet Code"],
          rapids_code: rapids_code,
          occupation_type: occupation_type,
          probationary_period_months: row["Probationary Period"],
          apprenticeship_to_journeyworker_ratio: row["Ratio of Apprentice to Journeyworker"],
          organization: organization,
          ojt_hours_min: row["Minimum OJT Hours"],
          ojt_hours_max: row["Maximum OJT Hours"],
          rsi_hours_min: row["Minimum RSI Hours"],
          rsi_hours_max: row["Maximum RSI Hours"],
        )
      end
    end
  end
end
