require "rails_helper"

RSpec.describe SimilarOccupationStandards, type: :model do
  describe ".similar_to", :elasticsearch do
    it "returns records that are similar to the passed occupation standard" do
      wa = create(:state, name: "Washington", abbreviation: "WA")
      al = create(:state, name: "Alabama", abbreviation: "AL")
      wa_reg_agency = create(:registration_agency, state: wa)
      al_reg_agency = create(:registration_agency, state: al)

      os1 = create(:occupation_standard, :time, title: "Childcare worker", registration_agency: wa_reg_agency)
      create(:work_process, title: "Principles of Child Growth and Development", occupation_standard: os1)
      create(:work_process, title: "Social and Emotional Development", occupation_standard: os1)

      # Matches on title, state
      os4 = create(:occupation_standard, :hybrid, title: "Childcare worker", registration_agency: wa_reg_agency)
      create(:work_process, title: "Vehicle Inspection", occupation_standard: os4)
      create(:work_process, title: "Tracking and Management Systems", occupation_standard: os4)

      # Matches on title, ojt_type
      os6 = create(:occupation_standard, :time, title: "Childcare worker", registration_agency: al_reg_agency)
      create(:work_process, title: "Vehicle Inspection", occupation_standard: os4)
      create(:work_process, title: "Tracking and Management Systems", occupation_standard: os4)

      # Matches on title, state, work process titles
      os2 = create(:occupation_standard, :hybrid, title: "Childcare worker", registration_agency: wa_reg_agency)
      create(:work_process, title: "Principles of Child Growth and Development", occupation_standard: os2)
      create(:work_process, title: "Social and Emotional Development", occupation_standard: os2)

      # Matches on title, work process titles
      os3 = create(:occupation_standard, :hybrid, title: "Childcare worker", registration_agency: al_reg_agency)
      create(:work_process, title: "Principles of Child Growth and Development", occupation_standard: os3)
      create(:work_process, title: "Social and Emotional Development", occupation_standard: os3)

      os5 = create(:occupation_standard, :hybrid, title: "Human Resource Specialist", registration_agency: al_reg_agency)
      create(:work_process, title: "Vehicle Inspection", occupation_standard: os5)
      create(:work_process, title: "Tracking Management Systems", occupation_standard: os5)

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      expect(described_class.similar_to(os1.reload)).to eq [os2, os3, os4, os6]
    end

    it "returns RESULTS_SIZE records" do
      stub_const("SimilarOccupationStandards::RESULTS_SIZE", 2)
      os1 = create(:occupation_standard, :time, title: "Childcare worker")
      create_list(:occupation_standard, 3, title: "Childcare worker")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      expect(described_class.similar_to(os1.reload).count).to eq 2
    end

    it "returns records when occupation standard's registration agency does not have state" do
      reg_agency = create(:registration_agency, state: nil)

      occupation_standard = create(:occupation_standard, :time, title: "Childcare worker", registration_agency: reg_agency)
      create(:occupation_standard, :time, title: "Childcare worker", registration_agency: reg_agency)

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      expect(described_class.similar_to(occupation_standard.reload).count).to eq 1
    end
  end
end
