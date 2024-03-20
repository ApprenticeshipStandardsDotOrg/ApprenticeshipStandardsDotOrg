require "rails_helper"

RSpec.describe ImportViaLLM::ProcessDataImport, type: :model do
  # TODO: for building the spec only -- REMOVE when mocks are good
  before do
  WebMock.allow_net_connect!
  end

  after do
  WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ["chromedriver.storage.googleapis.com"]
  )
  end

  describe "#work_processes" do
    context "when not an Appendix A" do
      it "changes nothing in the database" do
        mock_llm
        occupation_standard = create(:occupation_standard)
        attachment = file_fixture("process_data_example_01.pdf")

        expect {
          described_class.new(attachment:).work_processes(occupation_standard)
        }.not_to change(WorkProcess, :count)
      end

      it "produces empty array" do
        mock_llm
        occupation_standard = create(:occupation_standard)
        attachment = file_fixture("process_data_example_01.pdf")

        work_processes = described_class.new(attachment:).work_processes(occupation_standard)
        expect(work_processes).to be_empty
        expect(work_processes).to be_an Array
      end

      def mock_llm
        llm_mock = instance_double("LLM", call: "False")
        allow(LLM).to receive(:new).and_return(llm_mock)
      end
    end

    context "when an Appendix A with work processes" do
      it "imports work processes into the database" do
        data = mock_llm
        occupation_standard = create(:occupation_standard)
        attachment = file_fixture("process_data_example_13.pdf")

        expect {
          described_class.new(attachment:).work_processes(occupation_standard)
        }.to change(WorkProcess, :count).by(data.size)
      end

      it "makes array of imported work processes available" do
        data = mock_llm
        occupation_standard = create(:occupation_standard)
        attachment = file_fixture("process_data_example_13.pdf")

        work_processes = described_class.new(attachment:).work_processes(occupation_standard)
        expect(work_processes.size).to eq data.size

        first = work_processes.first
        expect(first.description).to eq data.keys.first
        expect([first.minimum_hours, first.maximum_hours]).to eq data.values.first

        last = work_processes.last
        expect(last.description).to eq data.keys.last
        expect([last.minimum_hours, last.maximum_hours]).to eq data.values.last
      end

      def mock_llm
        llm_data = {
          "Introductory Period" => [500, 500],
          "Introduction to Elevators" => [1000, 1000],
          "Basics of Installing Elevator Components" => [1000, 1000],
          "Maintenance Practices and Testing" => [1000, 1000],
          "Electrical Safety and Theory" => [1000, 1000],
          "Elevator Doors and Equipment" => [300, 300],
          "Electric Traction Elevators" => [1400, 1400],
          "Electrical Wiring and Equipment" => [300, 300],
          "Hydraulics Theory and Installing" => [400, 400],
          "Basic Electronics and Fundamentals" => [600, 600],
          "Machinery Troubleshooting and Rope Replacement" => [400, 400],
          "Escalators and Moving Walks" => [300, 300],
          "Accessibility" => [300, 300]
        }

        llm_mock = instance_double("LLM")
        allow(llm_mock).to receive(:chat).and_return("True", llm_data.to_json)

#        allow(LLM).to receive(:new).and_return(llm_mock)

        llm_data
      end
    end

    context "when an Appendix A without work processes" do
      fit "imports work processes into the database" do
        data = mock_llm
        occupation_standard = create(:occupation_standard)
        attachment = file_fixture("process_data_example_11.pdf")

        expect {
          described_class.new(attachment:).work_processes(occupation_standard)
        }.not_to change(WorkProcess, :count)
      end

      it "produces an empty array" do
        data = mock_llm
        occupation_standard = create(:occupation_standard)
        attachment = file_fixture("process_data_example_11.pdf")

        work_processes = described_class.new(attachment:).work_processes(occupation_standard)
        expect(work_processes).to be_empty
        expect(work_processes).to be_an Array
      end

      def mock_llm
        # llm_data = {
        #   "Introductory Period" => [500, 500],
        #   "Introduction to Elevators" => [1000, 1000],
        #   "Basics of Installing Elevator Components" => [1000, 1000],
        #   "Maintenance Practices and Testing" => [1000, 1000],
        #   "Electrical Safety and Theory" => [1000, 1000],
        #   "Elevator Doors and Equipment" => [300, 300],
        #   "Electric Traction Elevators" => [1400, 1400],
        #   "Electrical Wiring and Equipment" => [300, 300],
        #   "Hydraulics Theory and Installing" => [400, 400],
        #   "Basic Electronics and Fundamentals" => [600, 600],
        #   "Machinery Troubleshooting and Rope Replacement" => [400, 400],
        #   "Escalators and Moving Walks" => [300, 300],
        #   "Accessibility" => [300, 300]
        # }

        llm_mock = instance_double("LLM")
        allow(llm_mock).to receive(:chat).and_return("True", "{}")

#        allow(LLM).to receive(:new).and_return(llm_mock)

        # llm_data
      end
    end
  end

  xdescribe "#competencies" do
    it "imports work processes into the database" do
      data = mock_llm
      occupation_standard = create(:occupation_standard)
      attachment = file_fixture("process_data_example_01.pdf")

      expect {
        described_class.new(attachment:).work_processes(occupation_standard)
      }.to change(WorkProcess, :count).by(data.size)
    end

    it "makes array of imported work processes available" do
      data = mock_llm
      occupation_standard = create(:occupation_standard)
      attachment = file_fixture("process_data_example_01.pdf")

      work_processes = described_class.new(attachment:).work_processes(occupation_standard)
      expect(work_processes.size).to eq data.size

      first = work_processes.first
      expect(first.description).to eq data.keys.first
      expect([first.minimum_hours, first.maximum_hours]).to eq data.values.first

      last = work_processes.last
      expect(last.description).to eq data.keys.last
      expect([last.minimum_hours, last.maximum_hours]).to eq data.values.last
    end

    def mock_llm
      llm_data = {
        # "Safety"=>[40, 40],
        # "CNG Engines"=>[200, 200],
        # "Diesel/ CNG Engines Diagnostics & Repair"=>[1, 1],
        # "Brakes"=>[480, 480],
        # "Steering and Suspension"=>[360, 360],
        # "Preventive Maintenance & Inspection"=>[1, 1],
        # "HVAC"=>[480, 480],
        # "Transmission & Drive Train"=>[480, 480],
        # "Electrical & Electronics"=>[1, 1],
        # "Bus Body Systems"=>[200, 200],
        # "Hand Tools & Fasteners"=>[60, 60]
      }

      llm_mock = instance_double("LLM", call: llm_data.to_json)

      allow(LLM).to receive(:new).and_return(llm_mock)

      llm_data
    end
  end
end
