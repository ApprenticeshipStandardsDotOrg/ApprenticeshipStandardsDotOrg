require "rails_helper"

RSpec.describe MatchAIOccupation do
  let(:pdf) { create(:imports_pdf) }

  def attempt(title:, code:, type: :time)
    create(:open_ai_import, import: pdf,
      occupation_standard: create(:occupation_standard, source: :ai_conversion, title: title, rapids_code: code, ojt_type: type),
      parsed_response: {"documentOccupationCount" => 2, "singleOccupation" => false})
  end

  it "matches code suffix variants only within a PDF" do
    other = attempt(title: "Nurse", code: "0824CB")
    target = attempt(title: "Electrician", code: "0159HY", type: :hybrid)
    baseline = build(:occupation_standard, title: "Electrician", rapids_code: "0159", ojt_type: :hybrid)

    expect(described_class.call([other, target], baseline)).to eq target
  end

  it "does not choose between ambiguous same-code occupations" do
    first = attempt(title: "Industrial Electrician", code: "0159")
    second = attempt(title: "Residential Electrician", code: "0159")
    baseline = build(:occupation_standard, title: "Electrician", rapids_code: "0159")

    expect(described_class.call([first, second], baseline)).to be_nil
  end

  it "uses a unique alternate title in a combined RAPIDS title" do
    first = attempt(title: "General Electrician (01)", code: nil)
    second = attempt(title: "Residential Electrician (02)", code: nil)
    baseline = build(:occupation_standard, title: "INSIDE WIREMAN\n GENERAL ELECTRICIAN (01)", rapids_code: "0159")

    expect(described_class.call([first, second], baseline)).to eq first
  end

  it "does not fall back to the first multi-occupation result when nothing matches" do
    first = attempt(title: "Nurse", code: "0824CB")
    baseline = build(:occupation_standard, title: "Electrician", rapids_code: "0159")

    expect(described_class.call([first], baseline)).to be_nil
  end
end
