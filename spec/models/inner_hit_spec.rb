require "rails_helper"

RSpec.describe InnerHit, type: :model do
  it "has a valid factory" do
    inner_hit = build(:inner_hit)

    expect(inner_hit.id).to be_present
    expect(inner_hit.title).to be_present
  end

  describe ".from_result" do
    it "returns empty array if inner_hits is empty" do
      expect(InnerHit.from_result([])).to be_empty
    end

    it "returns an array of InnerHit if inner_hits provided" do
      inner_hits = [
        {
          "_id" => 1,
          "_source" => {
            "title" => "First record"
          }
        },
        {
          "_id" => 2,
          "_source" => {
            "title" => "Second record"
          }
        }
      ]

      inner_hits_results = InnerHit.from_result(inner_hits)

      expect(inner_hits_results.count).to eq 2
      expect(inner_hits_results.first.id).to eq 1
      expect(inner_hits_results.first.title).to eq "First record"
      expect(inner_hits_results.second.id).to eq 2
      expect(inner_hits_results.second.title).to eq "Second record"
    end
  end
end
