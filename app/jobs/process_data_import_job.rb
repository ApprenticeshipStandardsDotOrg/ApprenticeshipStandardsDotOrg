class ProcessDataImportJob < ApplicationJob
  queue_as :default

  def perform(data_import)
    import_occupation_standard_details(data_import)
  end

  private

  def import_occupation_standard_details(data_import)
    occupation_standard = ImportOccupationStandardDetails.new(data_import).call
    occupation_standard.save!
  end
end
