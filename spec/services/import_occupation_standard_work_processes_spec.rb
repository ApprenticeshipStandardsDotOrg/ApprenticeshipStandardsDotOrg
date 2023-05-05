require "rails_helper"

RSpec.describe ImportOccupationStandardWorkProcesses do
  describe "#call" do
    context "when occupation standard is time-based" do
      it "creates work process records" do
        occupation_standard = create(:occupation_standard)
        data_import = create(:data_import)

        expect {
          described_class.new(
            occupation_standard: occupation_standard,
            data_import: data_import
          ).call
        }.to change(WorkProcess, :count).by(2)

        work_process_1 = WorkProcess.first
        expect(work_process_1.occupation_standard).to eq occupation_standard
        expect(work_process_1.sort_order).to eq 1
        expect(work_process_1.title).to eq "Safety"
        expect(work_process_1.description).to eq 'a. Demonstrate good safety practices; b. Demonstrate proper techniques for lifting and carrying; c. Exercise extreme caution when working around electricity, lines, and equipment; d. Maintain work area properly; e. Adhere to safety signs and color codes; f. Identify and report potential safety hazards; g. Practice ladder and scaffold safety; h. Safely operate manual hand tools and power hand tools; i. Properly handle gas cylinders, hoses, and regulators; j. Wear required safety equipment; k. Identify types of fire extinguishers and their proper uses; l. Practice fire safety when operating heating equipment or working with hot materials; m. Demonstrate safe practices when using flux; n. Demonstrate safe use of solvents; o. Read and interpret "SDS" sheets; p. Demonstrate awareness of confined spaces; q. Work safely around laser equipment; r. Identify hazardous materials on site (e.g. leaking gas, asbestos); s. Demonstrate awareness of OSHA guidelines; t. Administer first aid and CPR'
        expect(work_process_1.maximum_hours).to eq 1000
        expect(work_process_1.minimum_hours).to eq 500

        work_process_2 = WorkProcess.second
        expect(work_process_2.occupation_standard).to eq occupation_standard
        expect(work_process_2.sort_order).to eq 2
        expect(work_process_2.title).to eq "Basic Skills"
        expect(work_process_2.description).to eq "a. Demonstrate basic reading skills; b. Use good time management skills (i.e., efficient use of time on job site); c. Lay out and plan any given piping/plumbing installation (measure for hangers); d. Define plumbing/piping terminology; e. Read measuring devices; f. Read, interpret, and understand drawings; g. Sketch piping layout; h. Read and interpret submittals for rough-in information; i. Read and interpret specifications; j. Prepare bill of materials; k. Read and interpret applicable codes; l. Identify basic structural framing components; m. Use judgment for structural penetrations (i.e., drilling, cutting, notching); n. Solder 95/5 copper joint; o. Assemble soft and rigid lead-free copper joint; p. Silver braze copper join; q. Assemble plastic joint/connection; r. Perform general mathematical calculations; s. Read and interpret Americans with Disabilities Act (ADA) requirements; t. Obtain rigging certifications; u. Tack weld-pipe"
        expect(work_process_2.maximum_hours).to eq 1500
        expect(work_process_2.minimum_hours).to eq 800
      end
    end

    it "does not duplicate work processes if they have the same title" do
      occupation_standard = create(:occupation_standard)
      data_import = create(:data_import, :with_multiple_work_processes_with_same_title)

      expect {
        described_class.new(
          occupation_standard: occupation_standard,
          data_import: data_import
        ).call
      }.to change(WorkProcess, :count).by(4)
        .and change(Competency, :count).by(23)

      work_process_1 = WorkProcess.first
      work_process_2 = WorkProcess.second
      work_process_3 = WorkProcess.third
      work_process_4 = WorkProcess.fourth

      expect(work_process_1.competencies.count).to eq 5
      expect(work_process_2.competencies.count).to eq 14
      expect(work_process_3.competencies.count).to eq 2
      expect(work_process_4.competencies.count).to eq 2
    end

    context "when occupation standard is hybrid with max and min hours" do
      it "creates work process records with its corresponding competencies" do
        occupation_standard = create(:occupation_standard)
        data_import = create(:data_import, :hybrid)

        expect {
          described_class.new(
            occupation_standard: occupation_standard,
            data_import: data_import
          ).call
        }.to change(WorkProcess, :count).by(2)
          .and change(Competency, :count).by(5)

        work_process_1 = WorkProcess.first
        work_process_2 = WorkProcess.second

        expect(work_process_1.competencies.count).to eq 2
        expect(work_process_2.competencies.count).to eq 3

        competency_1_for_work_process_1, competency_2_for_work_process_1 = work_process_1.competencies

        expect(competency_1_for_work_process_1.title).to eq "Nurtures relationships with children by valuing each child's individuality"
        expect(competency_1_for_work_process_1.sort_order).to eq 1

        expect(competency_2_for_work_process_1.title).to eq "Assists in maintaining an inclusive environment for all children; carries out activities that support children's IFSP/IEP goals"
        expect(competency_2_for_work_process_1.sort_order).to eq 2

        competency_1_for_work_process_2,
          competency_2_for_work_process_2,
          competency_3_for_work_process_2 = work_process_2.competencies

        expect(competency_1_for_work_process_2.title).to eq "Provides intentional activities to support children's development of a positive self-image, including the understanding of similarities and differences"
        expect(competency_1_for_work_process_2.sort_order).to eq 3

        expect(competency_2_for_work_process_2.title).to eq "Encourages children to express themselves in safe and appropriate ways to promote self-regulation"
        expect(competency_2_for_work_process_2.sort_order).to eq 4

        expect(competency_3_for_work_process_2.title).to eq "Engages in adult-child interactions, encouraging self-help skills and encouraging peer interactions"
        expect(competency_3_for_work_process_2.sort_order).to eq 5
      end
    end
  end
end
