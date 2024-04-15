require "rails_helper"

RSpec.describe RAPIDS::Competency, type: :model do
  describe ".initialize_from_response" do
    it "returns organization with correct data" do
      competency_response = create(:rapids_api_competency, title: "Competency #1")

      competency = described_class.initialize_from_response(competency_response)

      expect(competency.title).to eq "Competency #1"
    end

    it "sets the sort_order if provided" do
      competency_response = create(:rapids_api_competency)

      competency = described_class.initialize_from_response(
        competency_response.merge(
          {
            "sort_order" => 2
          }
        )
      )

      expect(competency.sort_order).to eq 2
    end
  end
end
