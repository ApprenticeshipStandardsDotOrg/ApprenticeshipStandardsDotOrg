require "rails_helper"

RSpec.describe WorkProcessExtractorJob, type: :job do
  describe "#perform" do
    context "with competency data" do
      it "populates db with both work process and competencies" do
        occupation_standard = create(:occupation_standard)
        competency_data = {skill_title: "Title", sort_order: "Asc"}
        chatgpt_data = {
          "Length of Training": [2, 2],
          "Related Supplemental (Classroom) Instruction": [144, 144],
          "On The Job Training": [2400, 2400],
          "Competency Evaluation": ["N/A", "N/A"]
        }
        chatgpt_mock = instance_double("ChatGptGenerateText", call: chatgpt_data.to_json)

        expect(ChatGptGenerateText).to receive(:new).and_return(chatgpt_mock)
        expect {
          described_class.perform_now(occupation_standard, competency_data)
        }.to change(WorkProcess, :count).by(4)
          .and change(Competency, :count).by(4)
      end
    end

    context "without competency data" do
      it "populates db with work process, but no competenies" do
        occupation_standard = create(:occupation_standard)
        chatgpt_data = {
          "Length of Training": [2, 2],
          "Related Supplemental (Classroom) Instruction": [144, 144],
          "On The Job Training": [2400, 2400],
          "Competency Evaluation": ["N/A", "N/A"]
        }
        chatgpt_mock = instance_double("ChatGptGenerateText", call: chatgpt_data.to_json)

        expect(ChatGptGenerateText).to receive(:new).and_return(chatgpt_mock)
        expect {
          described_class.perform_now(occupation_standard, nil)
        }.to change(WorkProcess, :count).by(4)
          .and change(Competency, :count).by(0)
      end
    end
  end
end
