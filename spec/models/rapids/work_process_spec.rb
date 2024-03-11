require "rails_helper"

RSpec.describe RAPIDS::WorkProcess, type: :model do
  describe ".initialize_from_response" do
    it "returns work process with correct data" do
      work_process_response = create(
        :rapids_api_work_process,
        title: "Sample work process",
        minHours: 20,
        maxHours: 200
      )

      work_process = RAPIDS::WorkProcess.initialize_from_response(work_process_response)

      expect(work_process.title).to eq "Sample work process"
      expect(work_process.minimum_hours).to eq 20
      expect(work_process.maximum_hours).to eq 200
    end
  end
end
