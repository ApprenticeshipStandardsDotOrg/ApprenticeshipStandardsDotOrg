require "rails_helper"

RSpec.describe ProcessDataImportJob, type: :job do
  describe "#perform" do
    it "calls ExtractOccupationStandard service" do
      data_import = build_stubbed(:data_import)
      service = instance_double("ExtractOccupationStandard")

      expect(ExtractOccupationStandard).to receive(:new).with(data_import).and_return(service)
      expect(service).to receive(:call)

      described_class.new.perform(data_import)
    end
  end
end
