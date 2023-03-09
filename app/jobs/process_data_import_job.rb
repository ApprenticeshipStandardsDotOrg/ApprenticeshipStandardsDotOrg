class ProcessDataImportJob < ApplicationJob
  queue_as :default

  def perform(data_import:)
    occupation_standard = import_occupation_standard_details(data_import)
    import_occupation_standard_related_instruction(occupation_standard, data_import)
    import_occupation_standard_wage_schedule(occupation_standard, data_import)
    import_occupation_standard_work_processes(occupation_standard, data_import)
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
end
