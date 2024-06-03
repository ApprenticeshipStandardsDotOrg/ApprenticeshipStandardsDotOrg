class ImportOccupationStandardWorkProcesses
  def initialize(occupation_standard:, data_import:)
    @occupation_standard = occupation_standard
    @data_import = data_import
    @row = nil
  end

  def call
    data_import.file.open do |file|
      xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
      sheet = xlsx.sheet(1)

      if work_processes_tab_has_data?(sheet)
        remove_existing_work_processes

        sheet.parse(headers: true).each_with_index do |row, index|
          next if index.zero?

          work_process = WorkProcess.find_or_initialize_by(
            occupation_standard: occupation_standard,
            title: row["Work Process Title"].presence
          )

          work_process.update!(
            description: row["Work Process Description"],
            minimum_hours: row["Minimum Hours"],
            maximum_hours: row["Maximum Hours"],
            sort_order: row["Work Process Sort Order"].presence || index
          )

          if competency_available?(row)
            work_process.competencies << create_or_update_competency(row, work_process)
          end
        end
      end
    end
  end

  private

  attr_reader :occupation_standard, :data_import, :row

  def work_processes_tab_has_data?(sheet)
    sheet.parse(headers: true).length > 1
  end

  def remove_existing_work_processes
    if occupation_standard.persisted?
      occupation_standard.work_processes.destroy_all
    end
  end

  def create_or_update_competency(row, work_process)
    Competency.find_or_initialize_by(
      sort_order: row["Skill Sort Order"],
      work_process: work_process
    ).tap do |competency|
      competency.update!(title: row["Skill Title"])
    end
  end

  def competency_available?(row)
    row["Skill Sort Order"].present? && row["Skill Title"].present?
  end
end
