class ProcessDataImportJob < ApplicationJob
  queue_as :default

  def perform(data_import:, last_file: false)
    occupation_standard = import_occupation_standard_details(data_import)
    import_occupation_standard_related_instruction(occupation_standard, data_import)
    import_occupation_standard_wage_schedule(occupation_standard, data_import)
    import_occupation_standard_work_processes(occupation_standard, data_import)
    mark_source_file_status(data_import, last_file)
    occupation_standard.in_review!
  end

  private

  def import_occupation_standard_details(data_import)
    ImportOccupationStandardDetails.new(data_import).call
  end

  def import_occupation_standard_related_instruction(occupation_standard, data_import)
    ImportOccupationStandardRelatedInstruction.new(
      occupation_standard: occupation_standard, data_import: data_import
    ).call
  end

  def import_occupation_standard_wage_schedule(occupation_standard, data_import)
    ImportOccupationStandardWageSchedule.new(
      occupation_standard: occupation_standard, data_import: data_import
    ).call
  end

  def import_occupation_standard_work_processes(occupation_standard, data_import)
    ImportOccupationStandardWorkProcesses.new(
      occupation_standard: occupation_standard, data_import: data_import
    ).call
  end

  def mark_source_file_status(data_import, last_file)
    if last_file
      data_import.source_file.completed!
    end
  end
end
