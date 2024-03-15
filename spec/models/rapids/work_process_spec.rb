require "rails_helper"

RSpec.describe RAPIDS::WorkProcess, type: :model do
  describe ".initialize_from_response" do
    it "returns work process with correct data" do
      work_process_response = create(
        :rapids_api_detailed_work_activity,
        title: "Sample work process",
        minHours: 20,
        maxHours: 200
      )

      work_process = described_class.initialize_from_response(work_process_response)

      expect(work_process.title).to eq "Sample work process"
      expect(work_process.minimum_hours).to eq 20
      expect(work_process.maximum_hours).to eq 200
    end

    it "returns work process with competencies if available" do
      work_process_response = create(
        :rapids_api_detailed_work_activity,
        tasks: ["Competency #1; Competency #2;Competency #3"]
      )

      work_process = described_class.initialize_from_response(work_process_response)

      (first_competency, second_competency, third_competency) = work_process.competencies

      expect(work_process.competencies.size).to eq 3
      expect(first_competency.title).to eq "Competency #1"
      expect(second_competency.title).to eq "Competency #2"
      expect(third_competency.title).to eq "Competency #3"
    end

    it "returns correct number of competencies regardless of extra or missing spacing" do
      work_process_response = create(
        :rapids_api_detailed_work_activity,
        tasks: ["Competency #1 ; Competency #2;Competency #3"]
      )

      work_process = described_class.initialize_from_response(work_process_response)

      (first_competency, second_competency, third_competency) = work_process.competencies

      expect(work_process.competencies.size).to eq 3
      expect(first_competency.title).to eq "Competency #1"
      expect(second_competency.title).to eq "Competency #2"
      expect(third_competency.title).to eq "Competency #3"
    end
  end
end
