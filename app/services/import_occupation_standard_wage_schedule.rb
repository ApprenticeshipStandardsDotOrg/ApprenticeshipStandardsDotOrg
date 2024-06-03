class ImportOccupationStandardWageSchedule
  attr_reader :occupation_standard, :data_import, :row

  def initialize(occupation_standard:, data_import:)
    @occupation_standard = occupation_standard
    @data_import = data_import
    @row = nil
  end

  def call
    remove_existing_wage_steps(occupation_standard)

    data_import.file.open do |file|
      xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
      sheet = xlsx.sheet(3)

      sheet.parse(headers: true).each_with_index do |row, index|
        next if index.zero?

        wage_schedule = WageStep.find_or_initialize_by(
          occupation_standard: occupation_standard,
          sort_order: row["Step Sort Order"]
        )

        wage_schedule.update!(
          title: row["Step Level Title"].presence || "Step #{index}",
          minimum_hours: row["Step OJT Hours"],
          ojt_percentage: row["Step OJT Percentage"],
          duration_in_months: row["Step Duration"],
          rsi_hours: row["Step RSI Hours"]
        )
      end
    end
  end

  private

  def remove_existing_wage_steps(occupation_standard)
    if occupation_standard.persisted?
      occupation_standard.wage_steps.destroy_all
    end
  end
end
