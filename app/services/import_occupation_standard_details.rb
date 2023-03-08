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
      occupation_standard = data_import.occupation_standard || data_import.build_occupation_standard

      remove_existing_associations(occupation_standard)

      occupation_standard.assign_attributes(
        occupation: occupation,
        registration_agency: registration_agency,
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
        rsi_hours_max: row["Maximum RSI Hours"]
      )
      DataImport.transaction do
        data_import.save!
        occupation_standard.save!
      end
      occupation_standard
    end
  end

  private

  def registration_agency
    state = State.find_by(abbreviation: row["Registration State"])
    RegistrationAgency.find_by(state: state, agency_type: row["OA or SAA"].downcase.to_sym)
  end

  def organization
    if (sponsor_name = row["Sponsor Name"])
      Organization.find_or_create_by!(title: sponsor_name)
    end
  end

  def rapids_code
    @_rapids_code ||= if (match = row["RAPIDS Code"].match(/(.*)[A-Za-z]{2}\z/))
      match.captures.first
    end
  end

  def occupation_type
    case row["Type"]
    when /competency/i
      :competency
    when /time/i
      :time
    when /hybrid/i
      :hybrid
    end
  end

  def occupation
    Occupation.find_by(rapids_code: rapids_code) || begin
      onet_code = OnetCode.find_by(code: row["Onet Code"])
      if onet_code
        Occupation.find_by(onet_code: onet_code)
      end
    end
  end

  def remove_existing_associations(occupation_standard)
    if occupation_standard.persisted?
      occupation_standard.related_instructions.destroy_all
      occupation_standard.wage_steps.destroy_all
      occupation_standard.work_processes.destroy_all
    end
  end
end
