require "rails_helper"

RSpec.describe ProcessDataImportJob, type: :job do
  describe "#perform" do
    it "calls ExtractOccupationStandard service" do
      data_import = build_stubbed(:data_import)
      service = instance_double("ExtractOccupationStandard")

      expect(ExtractOccupationStandard).to receive(:new).with(data_import).and_return(service)
      expect(service).to receive(:call).and_return(build(:occupation))

      described_class.new.perform(data_import)
    end

    it "creates an occupation standard when new record" do
      data_import = build_stubbed(:data_import)
      occupation_standard = build(:occupation_standard)
      service = instance_double("ExtractOccupationStandard")

      allow(ExtractOccupationStandard).to receive(:new).with(data_import).and_return(service)
      allow(service).to receive(:call).and_return(occupation_standard)

      expect {
        described_class.new.perform(data_import)
      }.to change(OccupationStandard, :count).by(1)
    end

    it "updates an occupation standard when it exists" do
      data_import = create(:data_import)
      occupation_standard = create(:occupation_standard, data_import: data_import)
      service = instance_double("ExtractOccupationStandard")

      allow(ExtractOccupationStandard).to receive(:new).with(data_import).and_return(service)
      allow(service).to receive(:call).and_return(occupation_standard)

      expect {
        described_class.new.perform(data_import)
      }.to_not change(OccupationStandard, :count)
    end
  end
end
