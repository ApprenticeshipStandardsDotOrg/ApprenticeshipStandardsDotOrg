require "rails_helper"

RSpec.describe ProcessDataImportJob, type: :job do
  describe "#perform" do
    it "calls the separate services to process each tab of the file" do
      ca = create(:state, abbreviation: "CA")
      create(:registration_agency, state: ca, agency_type: :oa)
      data_import = create(:data_import, :pending)
      create(:industry, prefix: "13")

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

      expect_any_instance_of(OccupationStandard).to receive(:update_document).twice

      described_class.new.perform(data_import: data_import)

      expect(data_import.source_file).to be_pending
    end

    it "deletes old related instructions, wage schedules, work processes when editing" do
      ca = create(:state, abbreviation: "CA")
      create(:registration_agency, state: ca, agency_type: :oa)
      data_import = create(:data_import)
      occupation_standard = data_import.occupation_standard
      create(:related_instruction, occupation_standard: occupation_standard, sort_order: 99)
      create(:wage_step, occupation_standard: occupation_standard, sort_order: 99)
      work_process = create(:work_process, occupation_standard: occupation_standard, sort_order: 99)
      create(:competency, work_process: work_process)
      create(:industry, prefix: "13")

      occupation_standard.reload

      described_class.new.perform(data_import: data_import)

      occupation_standard.reload
      aggregate_failures do
        expect(occupation_standard.related_instructions.count).to eq 4
        expect(occupation_standard.wage_steps.count).to eq 3
        expect(occupation_standard.work_processes.count).to eq 2
        expect(Competency.count).to eq 0
      end
    end

    it "marks the associated source file as complete if last_file is true, marks the occupation standard as in_review, and marks data_import as completed" do
      ca = create(:state, abbreviation: "CA")
      create(:registration_agency, state: ca, agency_type: :oa)
      data_import = create(:data_import, :pending)
      create(:industry, prefix: "13")

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

      described_class.new.perform(data_import: data_import, last_file: true)

      expect(data_import.reload).to be_completed
      expect(data_import.source_file).to be_completed
      expect(OccupationStandard.last).to be_in_review
    end
  end
end
