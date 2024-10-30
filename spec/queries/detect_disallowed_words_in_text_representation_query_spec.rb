require "rails_helper"

RSpec.describe DetectDisallowedWordsInTextRepresentationQuery do
  it "returns no result if no WordReplacement found" do
    text_representation = create(:text_representation, content: "Sample content")

    result = described_class.run(text_representation.id)

    expect(result).to be_nil
  end

  it "returns no result if no match found" do
    create(:word_replacement, word: "bad")
    text_representation = create(:text_representation, content: "Sample content with a slur we want to detect and remove")

    result = described_class.run(text_representation.id)

    expect(result).to be_nil
  end

  it "returns single match if WordReplacement has a match" do
    create(:word_replacement, word: "slur")
    text_representation = create(:text_representation, content: "Sample content with a slur we want to detect and remove")

    result = described_class.run(text_representation.id)

    expect(result).to eq "{slur}"
  end

  it "returns multiple matches if WordReplacement has more that one entry" do
    create(:word_replacement, word: "SLUR")
    create(:word_replacement, word: "bad")
    text_representation = create(:text_representation, content: "Sample content with a slur and a bad slur we want to detect and remove")

    result = described_class.run(text_representation.id)

    expect(result).to eq "{slur,bad,slur}"
  end
end
