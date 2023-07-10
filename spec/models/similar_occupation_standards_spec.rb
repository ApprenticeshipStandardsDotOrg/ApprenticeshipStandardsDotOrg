require "rails_helper"

RSpec.describe SimilarOccupationStandards, type: :model do
  describe ".similar_to", :elasticsearch do
    it "returns records that are similar to the passed occupation standard" do
      wa = create(:state, name: "Washington", abbreviation: "WA")
      al = create(:state, name: "Alabama", abbreviation: "AL")
      wa_reg_agency = create(:registration_agency, state: wa)
      al_reg_agency = create(:registration_agency, state: al)

      os1 = create(:occupation_standard, :time, title: "Childcare worker", registration_agency: wa_reg_agency)
      wp1a = create(:work_process, title: "Principles of Child Growth and Development", occupation_standard: os1)
      wp1b = create(:work_process, title: "Social and Emotional Development", occupation_standard: os1)

      os4 = create(:occupation_standard, :hybrid, title: "Childcare worker", registration_agency: wa_reg_agency)
      wp4a = create(:work_process, title: "Vehicle Inspection", occupation_standard: os4)
      wp4b = create(:work_process, title: "Tracking and Management Systems", occupation_standard: os4)

      os2 = create(:occupation_standard, :hybrid, title: "Childcare worker", registration_agency: wa_reg_agency)
      wp2a = create(:work_process, title: "Principles of Child Growth and Development", occupation_standard: os2)
      wp2b = create(:work_process, title: "Social and Emotional Development", occupation_standard: os2)

      os3 = create(:occupation_standard, :hybrid, title: "Childcare worker", registration_agency: al_reg_agency)
      wp3a = create(:work_process, title: "Principles of Child Growth and Development", occupation_standard: os3)
      wp3b = create(:work_process, title: "Social and Emotional Development", occupation_standard: os3)

      os5 = create(:occupation_standard, :hybrid, title: "Human Resource Specialist", registration_agency: al_reg_agency)
      wp5a = create(:work_process, title: "Vehicle Inspection", occupation_standard: os5)
      wp5b = create(:work_process, title: "Tracking and Management Systems", occupation_standard: os5)

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      expect(described_class.similar_to(os1.reload)).to eq [os2, os3, os4]
    end
  end
end
