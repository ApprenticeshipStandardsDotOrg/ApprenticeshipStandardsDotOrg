require "rails_helper"

RSpec.describe ImportViaLLM::WorkProcesses, type: :model do
  describe ".import" do
    it "populates db with a work process" do
      occupation_standard = create(:occupation_standard)
      description = "Length of Training"
      hour_bounds = [2, 2]

      expect {
        described_class.import(occupation_standard:, description:, hour_bounds:)
      }.to change(WorkProcess, :count).by(1)
    end

    it "returns resulting work process object" do
      occupation_standard = create(:occupation_standard)
      description = "Length of Training"
      hour_bounds = [2, 2]

      work_process = described_class.import(occupation_standard:, description:, hour_bounds:)
      expect(work_process.description).to eq description
      expect(work_process.title).to eq description
      expect(work_process.occupation_standard).to be occupation_standard
      expect(work_process.default_hours).to be_nil
      expect([work_process.minimum_hours, work_process.maximum_hours]).to eq hour_bounds
      expect(work_process.sort_order).to be_nil
      expect(work_process.competencies_count).to eq 0
    end
  end

  describe "#import" do
    it "populates db with a work process" do
      occupation_standard = create(:occupation_standard)
      description = "Length of Training"
      hour_bounds = [2, 2]

      expect {
        described_class.new(occupation_standard:, description:, hour_bounds:).import
      }.to change(WorkProcess, :count).by(1)
    end

    it "returns resulting work process object" do
      occupation_standard = create(:occupation_standard)
      description = "Length of Training"
      hour_bounds = [2, 2]

      work_process = described_class.new(occupation_standard:, description:, hour_bounds:).import
      expect(work_process.description).to eq description
      expect(work_process.title).to eq description
      expect(work_process.occupation_standard).to be occupation_standard
      expect(work_process.default_hours).to be_nil
      expect([work_process.minimum_hours, work_process.maximum_hours]).to eq hour_bounds
      expect(work_process.sort_order).to be_nil
      expect(work_process.competencies_count).to eq 0
    end
  end
end
