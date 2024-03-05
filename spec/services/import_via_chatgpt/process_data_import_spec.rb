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

  it 'retrieves work processes' do
    occupation_standard = create(:occupation_standard)
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

    attachment = file_fixture("process_data_example_01.pdf")

    expect {
      described_class.new(attachment:).work_processes(occupation_standard, nil)
    }.to change(WorkProcess, :count).by(16).and change(Competency, :count).by(0)
  end
end
