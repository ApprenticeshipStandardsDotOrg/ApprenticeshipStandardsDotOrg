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
            title: "First record"
          }
        },
        {
          "_id" => 2,
          "_source" => {
            title: "Second record"
          }
        }
      ]

      expect(InnerHit.from_result(inner_hits).count).to eq 2
    end
  end
end
