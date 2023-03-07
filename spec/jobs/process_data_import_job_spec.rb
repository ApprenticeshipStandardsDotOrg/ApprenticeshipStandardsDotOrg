require "rails_helper"

RSpec.describe ProcessDataImportJob, type: :job do
  describe "#perform" do
    it "calls the separate services to process each tab of the file" do
      ca = create(:state, abbreviation: "CA")
      create(:registration_agency, state: ca, agency_type: :oa)
      data_import = create(:data_import, :unprocessed)

      related_inst_mock = instance_double("ImportOccupationStandardRelatedInstruction")
      wage_schedule_mock = instance_double("ImportOccupationStandardWageSchedule")
      work_processes_mock = instance_double("ImportOccupationStandardWorkProcesses")

      expect(ImportOccupationStandardRelatedInstruction).to receive(:new).with(
        occupation_standard: kind_of(OccupationStandard),
        data_import: data_import
      ).and_return(related_inst_mock)
      expect(related_inst_mock).to receive(:call)

      expect(ImportOccupationStandardWageSchedule).to receive(:new).with(
        occupation_standard: kind_of(OccupationStandard),
        data_import: data_import
      ).and_return(wage_schedule_mock)
      expect(wage_schedule_mock).to receive(:call)

      expect(ImportOccupationStandardWorkProcesses).to receive(:new).with(
        occupation_standard: kind_of(OccupationStandard),
        data_import: data_import
      ).and_return(work_processes_mock)
      expect(work_processes_mock).to receive(:call)

      described_class.new.perform(data_import)
    end
  end
end
