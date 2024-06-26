class ProcessDataImportJob < ApplicationJob
  queue_as :default

  def perform(data_import:, last_file: false)
    data_import.importing!

    occupation_standard = import_occupation_standard_details(data_import)
    import_occupation_standard_related_instruction(occupation_standard, data_import)
    import_occupation_standard_wage_schedule(occupation_standard, data_import)
    import_occupation_standard_work_processes(occupation_standard, data_import)

    update_status_fields(
      data_import: data_import,
      occupation_standard: occupation_standard,
      last_file: last_file
    )
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

  def update_status_fields(data_import:, occupation_standard:, last_file:)
    data_import.completed!
    occupation_standard.in_review!

    if last_file
      data_import.import.completed!
    end

    # We need to reload the occupation prior to updating ES for the application
    # to have all the updated data.
    occupation_standard.reload
    occupation_standard.update_document
  end
end
