class ImportOccupationStandardWorkProcesses
  attr_reader :occupation_standard, :data_import, :row

  def initialize(occupation_standard:, data_import:)
    @occupation_standard = occupation_standard
    @data_import = data_import
    @row = nil
  end

  def call
    work_processes = []
    data_import.file.open do |file|
      xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
      sheet = xlsx.sheet(1)

      sheet.parse(headers: true).each_with_index do |row, index|
        next if index.zero?

        work_process = WorkProcess.find_or_initialize_by(
          occupation_standard: occupation_standard,
          sort_order: row["Work Process Sort Order"]
        )

        work_process.assign_attributes(
          title: row["Work Process Title"],
          description: row["Work Process Description"],
          minimum_hours: row["Minimum Hours"],
          maximum_hours: row["Maximum Hours"]
        )

        work_process.save!

        if competency_available?(row)
          work_process.competencies << create_or_update_competency(row, work_process)
        end

        work_processes << work_process
      end
    end
    work_processes.uniq
  end

  private

  def create_or_update_competency(row, work_process)
    Competency.find_or_initialize_by(
      sort_order: row["Skill Sort Order"],
      work_process: work_process
    ).tap do |competency|
      competency.assign_attributes(
        title: row["Skill Title"]
      )

      competency.save!
    end
  end

  def competency_available?(row)
    row["Skill Sort Order"].presence && row["Skill Title"].presence
  end
end
