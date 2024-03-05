require "rails_helper"

RSpec.describe ImportViaChatgpt::ProcessDataImport, type: :model do

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

  describe '#work_processes' do
    it 'imports work processes into the database' do
      data = mock_chatgpt
      occupation_standard = create(:occupation_standard)
      attachment = file_fixture("process_data_example_01.pdf")

      expect {
        described_class.new(attachment:).work_processes(occupation_standard)
      }.to change(WorkProcess, :count).by(data.size)
    end

    it 'makes array of imported work processes available' do
      data = mock_chatgpt
      occupation_standard = create(:occupation_standard)
      attachment = file_fixture("process_data_example_01.pdf")

      work_processes = described_class.new(attachment:).work_processes(occupation_standard)
      expect(work_processes.size).to eq 16

      first = work_processes.first
      expect(first.description).to eq data.keys.first
      expect([first.minimum_hours, first.maximum_hours]).to eq data.values.first

      last = work_processes.last
      expect(last.description).to eq data.keys.last
      expect([last.minimum_hours, last.maximum_hours]).to eq data.values.last
    end
  end

  def mock_chatgpt
    chatgpt_data = {
      "Safety"=>[40, 40],
      "CNG Engines"=>[200, 200],
      "Diesel/CNG Engines Diagnostics & Repair"=>[1100, 1100],
      "Brakes"=>[480, 480],
      "Steering and Suspension"=>[360, 360],
      "Preventive Maintenance & Inspection"=>[1000, 1000],
      "HVAC"=>[480, 480],
      "Transmission & Drive Train"=>[480, 480],
      "Electrical & Electronics"=>[1000, 1000],
      "Bus Body Systems"=>[200, 200],
      "Hand Tools & Fasteners"=>[60, 60],
      "Diesel Preventative Maintenance"=>[108, 108],
      "Diesel Engine Repair"=>[108, 108],
      "Basic Hydraulic Principles of Diesel Technology"=>[108, 108],
      "Diesel Brake Systems"=>[108, 108],
      "Diesel Electrical Systems"=>[108, 108]
    }
    chatgpt_mock = instance_double("ChatGptGenerateText", call: chatgpt_data.to_json)

    allow(ChatGptGenerateText).to receive(:new).and_return(chatgpt_mock)

    chatgpt_data
  end
end
