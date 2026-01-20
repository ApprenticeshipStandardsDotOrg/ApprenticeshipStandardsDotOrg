require "rails_helper"

RSpec.describe CompareAIToHuman do
  let(:occupation_standard) { create(:occupation_standard) }
  let(:service) { described_class.new(occupation_standard) }

  describe "#call" do
    context "when there is no open_ai_import" do
      it "returns nil" do
        expect(service.call).to be_nil
      end
    end

    context "when there is no response in open_ai_import" do
      let!(:open_ai_import) { create(:open_ai_import, occupation_standard: occupation_standard, response: nil) }

      it "returns nil" do
        expect(service.call).to be_nil
      end
    end

    context "when there is valid open_ai_import data" do
      let!(:open_ai_import) do
        create(:open_ai_import, occupation_standard: occupation_standard, response: ai_response.to_json)
      end

      context "with matching work processes and related instructions" do
        let(:human_wp1) { create(:work_process, occupation_standard: occupation_standard, title: "Installation and Setup", description: "Install equipment") }
        let(:human_wp2) { create(:work_process, occupation_standard: occupation_standard, title: "Maintenance Procedures", description: "Maintain systems") }
        let(:human_ri1) { create(:related_instruction, occupation_standard: occupation_standard, title: "Safety Training", hours: 40) }
        let(:human_ri2) { create(:related_instruction, occupation_standard: occupation_standard, title: "Technical Skills", hours: 80) }

        let(:ai_response) do
          {
            "workProcesses" => [
              { "title" => "Installation and Setup", "description" => "Install equipment", "competencies" => [] },
              { "title" => "Maintenance Procedures", "description" => "Maintain systems", "competencies" => [] }
            ],
            "relatedInstructions" => [
              { "title" => "Safety Training", "hours" => 40 },
              { "title" => "Technical Skills", "hours" => 80 }
            ]
          }
        end

        before do
          human_wp1
          human_wp2
          human_ri1
          human_ri2
        end

        it "creates a comparison result with high scores" do
          result = service.call

          expect(result).to be_a(AIComparisonResult)
          expect(result.work_processes_score).to be > 80
          expect(result.related_instructions_score).to be > 80
          expect(result.overall_score).to be > 80
          expect(result.flagged_by_system).to be false
        end

        it "stores comparison details" do
          result = service.call

          wp_details = JSON.parse(result.work_processes_comparison_details)
          expect(wp_details["ai_count"]).to eq(2)
          expect(wp_details["human_count"]).to eq(2)

          ri_details = JSON.parse(result.related_instructions_comparison_details)
          expect(ri_details["ai_count"]).to eq(2)
          expect(ri_details["human_count"]).to eq(2)
          expect(ri_details["ai_total_hours"]).to eq(120)
          expect(ri_details["human_total_hours"]).to eq(120)
        end
      end

      context "with mismatched counts" do
        let(:human_wp1) { create(:work_process, occupation_standard: occupation_standard, title: "Work Process 1") }
        let(:human_wp2) { create(:work_process, occupation_standard: occupation_standard, title: "Work Process 2") }
        let(:human_wp3) { create(:work_process, occupation_standard: occupation_standard, title: "Work Process 3") }

        let(:ai_response) do
          {
            "workProcesses" => [
              { "title" => "Work Process 1", "description" => nil, "competencies" => [] }
            ],
            "relatedInstructions" => []
          }
        end

        before do
          human_wp1
          human_wp2
          human_wp3
        end

        it "calculates lower scores due to count mismatch" do
          result = service.call

          expect(result.work_processes_score).to be < 50
          expect(result.work_processes_score).to be > 0
        end
      end

      context "with similar but not identical titles (fuzzy matching)" do
        let(:human_wp1) { create(:work_process, occupation_standard: occupation_standard, title: "Installation and Setup") }

        let(:ai_response) do
          {
            "workProcesses" => [
              { "title" => "Installation & Setup", "description" => nil, "competencies" => [] }
            ],
            "relatedInstructions" => []
          }
        end

        before { human_wp1 }

        it "still matches titles with high similarity" do
          result = service.call

          expect(result.work_processes_score).to be > 60
        end
      end

      context "with completely different titles" do
        let(:human_wp1) { create(:work_process, occupation_standard: occupation_standard, title: "Work Process A") }

        let(:ai_response) do
          {
            "workProcesses" => [
              { "title" => "Work Process Z", "description" => nil, "competencies" => [] }
            ],
            "relatedInstructions" => []
          }
        end

        before { human_wp1 }

        it "calculates low title similarity scores" do
          result = service.call

          expect(result.work_processes_score).to be < 50
        end
      end

      context "with competencies matching" do
        let(:human_wp1) { create(:work_process, occupation_standard: occupation_standard, title: "Work Process 1") }
        let(:human_comp1) { create(:competency, work_process: human_wp1, title: "Install wiring") }
        let(:human_comp2) { create(:competency, work_process: human_wp1, title: "Test systems") }

        let(:ai_response) do
          {
            "workProcesses" => [
              {
                "title" => "Work Process 1",
                "description" => nil,
                "competencies" => [
                  { "title" => "Install wiring" },
                  { "title" => "Test systems" }
                ]
              }
            ],
            "relatedInstructions" => []
          }
        end

        before do
          human_wp1
          human_comp1
          human_comp2
        end

        it "includes competencies in the score calculation" do
          result = service.call

          # Should have good score because competencies match
          expect(result.work_processes_score).to be > 70
        end
      end

      context "with hours matching for related instructions" do
        let(:human_ri1) { create(:related_instruction, occupation_standard: occupation_standard, title: "Training", hours: 100) }
        let(:human_ri2) { create(:related_instruction, occupation_standard: occupation_standard, title: "Education", hours: 200) }

        let(:ai_response) do
          {
            "workProcesses" => [],
            "relatedInstructions" => [
              { "title" => "Training", "hours" => 100 },
              { "title" => "Education", "hours" => 200 }
            ]
          }
        end

        before do
          human_ri1
          human_ri2
        end

        it "calculates high scores when hours match" do
          result = service.call

          expect(result.related_instructions_score).to be > 80
        end
      end

      context "with hours mismatch for related instructions" do
        let(:human_ri1) { create(:related_instruction, occupation_standard: occupation_standard, title: "Training", hours: 100) }
        let(:human_ri2) { create(:related_instruction, occupation_standard: occupation_standard, title: "Education", hours: 200) }

        let(:ai_response) do
          {
            "workProcesses" => [],
            "relatedInstructions" => [
              { "title" => "Training", "hours" => 50 },
              { "title" => "Education", "hours" => 100 }
            ]
          }
        end

        before do
          human_ri1
          human_ri2
        end

        it "calculates lower scores when hours don't match" do
          result = service.call

          # Titles match but hours are off by 50%
          expect(result.related_instructions_score).to be < 80
          expect(result.related_instructions_score).to be > 40
        end
      end

      context "with empty arrays on both sides" do
        let(:ai_response) do
          {
            "workProcesses" => [],
            "relatedInstructions" => []
          }
        end

        it "returns 0.0 scores" do
          result = service.call

          expect(result.work_processes_score).to eq(0.0)
          expect(result.related_instructions_score).to eq(0.0)
          expect(result.overall_score).to eq(0.0)
        end
      end

      context "when AI has data but human doesn't" do
        let(:ai_response) do
          {
            "workProcesses" => [
              { "title" => "Work Process 1", "description" => nil, "competencies" => [] }
            ],
            "relatedInstructions" => [
              { "title" => "Instruction 1", "hours" => 40 }
            ]
          }
        end

        it "returns 0.0 scores" do
          result = service.call

          expect(result.work_processes_score).to eq(0.0)
          expect(result.related_instructions_score).to eq(0.0)
        end
      end

      context "when human has data but AI doesn't" do
        let(:human_wp1) { create(:work_process, occupation_standard: occupation_standard, title: "Work Process 1") }
        let(:human_ri1) { create(:related_instruction, occupation_standard: occupation_standard, title: "Instruction 1", hours: 40) }

        let(:ai_response) do
          {
            "workProcesses" => [],
            "relatedInstructions" => []
          }
        end

        before do
          human_wp1
          human_ri1
        end

        it "returns 0.0 scores" do
          result = service.call

          expect(result.work_processes_score).to eq(0.0)
          expect(result.related_instructions_score).to eq(0.0)
        end
      end

      context "overall score calculation" do
        let(:human_wp1) { create(:work_process, occupation_standard: occupation_standard, title: "Work Process 1") }
        let(:human_ri1) { create(:related_instruction, occupation_standard: occupation_standard, title: "Instruction 1", hours: 40) }

        let(:ai_response) do
          {
            "workProcesses" => [
              { "title" => "Work Process 1", "description" => nil, "competencies" => [] }
            ],
            "relatedInstructions" => [
              { "title" => "Instruction 1", "hours" => 40 }
            ]
          }
        end

        before do
          human_wp1
          human_ri1
        end

        it "calculates overall score as weighted average (60% work_processes, 40% related_instructions)" do
          result = service.call

          wp_score = result.work_processes_score
          ri_score = result.related_instructions_score
          expected_overall = (wp_score * 0.6) + (ri_score * 0.4)

          expect(result.overall_score).to be_within(0.5).of(expected_overall)
        end
      end

      context "flagging low scores" do
        let(:human_wp1) { create(:work_process, occupation_standard: occupation_standard, title: "Work Process A") }
        let(:human_ri1) { create(:related_instruction, occupation_standard: occupation_standard, title: "Instruction A", hours: 100) }

        let(:ai_response) do
          {
            "workProcesses" => [
              { "title" => "Work Process Z", "description" => nil, "competencies" => [] }
            ],
            "relatedInstructions" => [
              { "title" => "Instruction Z", "hours" => 10 }
            ]
          }
        end

        before do
          human_wp1
          human_ri1
        end

        it "flags results with overall_score < 70" do
          result = service.call

          if result.overall_score < 70
            expect(result.flagged_by_system).to be true
            expect(result.needs_review).to be true
          end
        end
      end

      context "updating existing comparison result" do
        let(:human_wp1) { create(:work_process, occupation_standard: occupation_standard, title: "Work Process 1") }

        let(:ai_response) do
          {
            "workProcesses" => [
              { "title" => "Work Process 1", "description" => nil, "competencies" => [] }
            ],
            "relatedInstructions" => []
          }
        end

        let!(:existing_result) do
          create(:ai_comparison_result, occupation_standard: occupation_standard, overall_score: 50.0)
        end

        before { human_wp1 }

        it "updates the existing result instead of creating a new one" do
          expect {
            service.call
          }.not_to change(AIComparisonResult, :count)

          existing_result.reload
          expect(existing_result.overall_score).not_to eq(50.0)
        end
      end
    end
  end

  describe "when comparing work processes with different counts" do
    # Additional edge case tests can be added here
  end
end

