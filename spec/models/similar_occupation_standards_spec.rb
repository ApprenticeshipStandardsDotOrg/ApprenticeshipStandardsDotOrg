require "rails_helper"

RSpec.describe SimilarOccupationStandards do
  describe ".similar_to", :elasticsearch do
    it "returns results to my search" do
      mechanic_standard = create(:occupation_standard, title: "Mechanic")
      medical_assistant_standard = create(:occupation_standard, title: "Medical Assistant")
      admin_assistant_standard = create(:occupation_standard, title: "Admin Assistant")
      medical_assistantII_standard = create(:occupation_standard, title: "Medical Assistant II")

      OccupationStandard.import
      sleep 1
      similars_to_medical_assistant = SimilarOccupationStandards.similar_to(medical_assistant_standard)

      expect(similars_to_medical_assistant.pluck(:title)).to match ["Admin Assistant", "Medical Assistant II"]
    end
  end
end
