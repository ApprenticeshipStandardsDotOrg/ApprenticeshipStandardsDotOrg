class ProcessDataImportJob < ApplicationJob
  queue_as :default

  def perform(data_import)
    occupation_standard = import_occupation_standard_details(data_import)
    import_occupation_standard_related_instruction(occupation_standard, data_import)
  end

  private

  def import_occupation_standard_details(data_import)
    occupation_standard = ImportOccupationStandardDetails.new(data_import).call
    occupation_standard.save!
    occupation_standard
  end

  def import_occupation_standard_related_instruction(occupation_standard, data_import)
    ImportOccupationStandardRelatedInstruction.new(occupation_standard: occupation_standard, data_import: data_import).call
  end
end
