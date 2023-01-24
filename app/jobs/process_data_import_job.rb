class ProcessDataImportJob < ApplicationJob
  queue_as :default

  def perform(data_import)
    occupation_standard = ExtractOccupationStandard.new(data_import).call
    occupation_standard.save!
  end
end
