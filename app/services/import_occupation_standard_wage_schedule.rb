class ImportOccupationStandardWageSchedule
  attr_reader :occupation_standard, :data_import, :row

  def initialize(occupation_standard:, data_import:)
    @occupation_standard = occupation_standard
    @data_import = data_import
    @row = nil
  end

  def call
    wage_schedules = []
    data_import.file.open do |file|
      xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
      sheet = xlsx.sheet(3)

      # sheet.parse(headers: true).each_with_index do |row, index|
      #   next if index.zero?

      #   wage_schedule = WageStep.find_or_initialize_by(
      #     occupation_standard: occupation_standard,
      #     sort_order: row["Step Sort Order"]
      #   )

      #   wage_schedule.assign_attributes(
      #     title: row["Step Level Title"],
      #     minimum_hours: row["Step OJT Hours"],
      #     ojt_percentage: row["Step OJT Percentage"],
      #     duration_in_months: row["Step Duration"],
      #     rsi_hours: row["Step RSI Hours"]
      #   )

      #   wage_schedules << wage_schedule
      # end
    end

    wage_schedules
  end

  private

end
