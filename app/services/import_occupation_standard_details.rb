class ImportOccupationStandardDetails
  attr_reader :data_import, :row

  def initialize(data_import)
    @data_import = data_import
    @row = nil
  end

  def call
    data_import.file.open do |file|
      xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
      sheet = xlsx.sheet(0)

      @row = sheet.parse(headers: true)[1]
      occupation_standard = build_or_retrieve_occupation_standard
      data_import.occupation_standard = occupation_standard

      occupation_standard.assign_attributes(
        occupation: occupation,
        national_standard_type: national_standard_type,
        registration_agency: registration_agency,
        title: row["Occupation Title"],
        existing_title: row["Existing Title"],
        term_months: row["Term (in months)"],
        onet_code: onet_code,
        industry: industry,
        rapids_code: rapids_code,
        ojt_type: ojt_type,
        probationary_period_months: row["Probationary Period"],
        apprenticeship_to_journeyworker_ratio: row["Ratio of Apprentice to Journeyworker"],
        organization: organization,
        ojt_hours_min: row["Minimum OJT Hours"],
        ojt_hours_max: row["Maximum OJT Hours"],
        rsi_hours_min: row["Minimum RSI Hours"],
        rsi_hours_max: row["Maximum RSI Hours"],
        registration_date: parse_date(row["Registration Date"]),
        latest_update_date: parse_date(row["Latest Registration Update"])
      )
      DataImport.transaction do
        data_import.save!
        occupation_standard.save!
      end
      occupation_standard
    end
  end

  private

  def build_or_retrieve_occupation_standard
    data_import.occupation_standard ||
      data_import.related_occupation_standard(row["Occupation Title"]) ||
      data_import.build_occupation_standard
  end

  def registration_agency
    agency_type = row["National"] ? :oa : row["OA or SAA"].downcase.to_sym
    state = row["National"] ? nil : State.find_by(abbreviation: row["Registration State"])
    RegistrationAgency.find_by(state: state, agency_type: agency_type)
  end

  def organization
    if (sponsor_name = row["Sponsor Name"])
      Organization.find_or_create_by!(title: sponsor_name)
    end
  end

  def rapids_code
    parsed_rapids_code || occupation&.rapids_code
  end

  def parsed_rapids_code
    if (rapids = row["RAPIDS Code"])
      rapids = rapids.to_s.gsub(/[A-Za-z]+\z/, "").to_i
      sprintf("%04d", rapids)
    end
  end

  def onet_code
    @_onet_code ||= row["Onet Code"].presence || occupation&.onet_code
  end

  def industry
    if onet_code
      matches = onet_code.match(/\A(?<prefix>\d{2})/)
      if matches
        Industry.where(prefix: matches[:prefix], version: Industry::CURRENT_VERSION).sole
      end
    end
  end

  def ojt_type
    case row["Type"]
    when /competency/i
      :competency
    when /time|hour/i
      :time
    when /hybrid/i
      :hybrid
    end
  end

  def national_standard_type
    if (national_type = row["National"])
      national_type.downcase.gsub(/\Anational\s*/, "").gsub(/\s+/, "_").singularize
    end
  end

  def occupation
    @_occupation ||= Occupation.find_by(rapids_code: parsed_rapids_code) || begin
      onet = Onet.find_by(code: row["Onet Code"])
      if onet
        Occupation.find_by(onet: onet)
      end
    end
  end

  def parse_date(date)
    Date.parse(date.to_s)
  rescue Date::Error
    nil
  end
end
