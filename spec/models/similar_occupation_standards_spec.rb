require "rails_helper"

RSpec.describe SimilarOccupationStandards do
  describe ".similar_to" do
    it "returns" do
      mechanic_standard = create(:occupation_standard, title: "Mechanic")
      medical_assistant_standard = create(:occupation_standard, title: "Medical Assistant")
      admin_assistant_standard = create(:occupation_standard, title: "Admin Assistant")
      medical_assistantII_standard = create(:occupation_standard, title: "Medical Assistant II") 

      similars_to_medical_assistant = SimilarOccupationStandards.similar_to(medical_assistant_standard)

      expect(similars_to_medical_assistant.count).to eq 2
      expect(similars_to_medical_assistant.first).to eq medical_assistantII_standard
    end
  end
end
