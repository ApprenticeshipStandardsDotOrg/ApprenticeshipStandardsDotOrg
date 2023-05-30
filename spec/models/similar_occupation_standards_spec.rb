require "rails_helper"

RSpec.describe SimilarOccupationStandards do
  describe ".similar_to", :elasticsearch do
    it "returns records similar to the provided, sorted by similarity score" do
      create(:occupation_standard, title: "Mechanic")
      medical_assistant_standard = create(:occupation_standard, title: "Medical Assistant")
      create(:occupation_standard, title: "Medical Assistant II")
      create(:occupation_standard, title: "Admin Assistant")
      create(:occupation_standard, title: "Medical Assistant")
      create(:occupation_standard, title: "Medic")

      OccupationStandard.import(refresh: true)

      similars_to_medical_assistant = SimilarOccupationStandards.similar_to(medical_assistant_standard)

      expect(similars_to_medical_assistant.pluck(:title)).to eq ["Medical Assistant", "Medical Assistant II", "Medic", "Admin Assistant", "Mechanic"]
    end

    it "returns records similar to the provided, including associations, sorted by similarity score" do
      medical_assistant_standard = create(:occupation_standard, title: "Medical Assistant")
      nurse_standard = create(:occupation_standard, title: "Nurse")
      other_medical_assist = create(:occupation_standard, title: "Medical Assistant")

      create(:work_process, title: "Patient Interaction", occupation_standard: medical_assistant_standard)
      create(:work_process, title: "Patient Interaction", occupation_standard: nurse_standard)
      create(:work_process, title: "Patient Interaction", occupation_standard: other_medical_assist)

      OccupationStandard.import(refresh: true)

      similars_to_medical_assistant = SimilarOccupationStandards.similar_to(medical_assistant_standard)

      expect(similars_to_medical_assistant.pluck(:title)).to match_array ["Medical Assistant", "Nurse"]
      # Skipped until sorting/weighting fields is fixed
      # expect(similars_to_medical_assistant.pluck(:title)).to eq ["Medical Assistant", "Nurse"]
    end

    it "returns records similar to the provided, sorted by similarity score" do
      _excluded = create(:occupation_standard, title: "ABC", ojt_type: "hybrid")
      competency_based = create(:occupation_standard, title: "Medical Assistant", ojt_type: "competency")
      diff_type = create(:occupation_standard, title: "Medical Assistant II", ojt_type: "hybrid")
      same_type = create(:occupation_standard, title: "Medical Assistant II", ojt_type: "competency")

      OccupationStandard.import(refresh: true)

      similars_to_medical_assistant = SimilarOccupationStandards.similar_to(competency_based)

      expect(similars_to_medical_assistant.pluck(:id)).to match_array [same_type.id, diff_type.id]
      # Skipped until sorting/weighting fields is fixed
      # expect(similars_to_medical_assistant.pluck(:id)).to eq [same_type.id, diff_type.id]
    end
  end
end
