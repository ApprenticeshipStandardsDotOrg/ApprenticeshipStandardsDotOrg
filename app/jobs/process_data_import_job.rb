class ProcessDataImportJob < ApplicationJob
  queue_as :default

  def perform(data_import)
    ExtractOccupationStandard.new(data_import).call
  end
end
