require "rails_helper"

RSpec.describe Synonym, type: :model do
  it "has a valid factory" do
    synonym = build(:synonym)

    expect(synonym).to be_valid
  end

  describe "#to_elasticsearch_value" do
    it "returns a comma-separated list with word and single-word synonym" do
      synonym = build_stubbed(:synonym, word: "Graphic Designer", synonyms: "Designer")

      expect(synonym.to_elasticsearch_value).to eq "Graphic Designer,Designer"
    end

    it "returns a comma-separated list with word and single-word synonym that uses a special character" do
      synonym = build_stubbed(:synonym, word: "UX", synonyms: "UI/UX")

      expect(synonym.to_elasticsearch_value).to eq "UX,UI/UX"
    end

    it "returns a comma-separated list with word and multiple-word synonym" do
      synonym = build_stubbed(:synonym, word: "UX", synonyms: "User Experience")

      expect(synonym.to_elasticsearch_value).to eq "UX,User Experience"
    end

    it "returns a comma-separated list with word and a list of synonyms" do
      synonym = build_stubbed(
        :synonym,
        word: "UX designer",
        synonyms: "User Experience, User experience designer, UX/UI designer"
      )

      expect(
        synonym.to_elasticsearch_value
      ).to eq "UX designer,User Experience, User experience designer, UX/UI designer"
    end
  end

  describe "#synonyms" do
    it "supports a single-word synonym" do
      synonym = build_stubbed(:synonym, word: "Graphic Designer", synonyms: "Designer")

      expect(synonym).to be_valid
    end

    it "supports a single-word synonym that uses a special character" do
      synonym = build_stubbed(:synonym, word: "UX", synonyms: "UI/UX")

      expect(synonym).to be_valid
    end

    it "supports a multiple-word synonym" do
      synonym = build_stubbed(:synonym, word: "UX", synonyms: "User Experience")

      expect(synonym).to be_valid
    end

    it "supports a comma-separated list of synonyms" do
      synonym = build_stubbed(
        :synonym,
        word: "UX designer",
        synonyms: "User Experience, User experience designer, UX/UI designer"
      )

      expect(synonym).to be_valid
    end

    it "rejects a dot-separated list" do
      synonym = build_stubbed(
        :synonym,
        word: "UX designer",
        synonyms: "User Experience. User experience designer. UX UI designer"
      )

      expect(synonym).to_not be_valid
    end
  end

  describe "#add_to_elastic_search_synonyms" do
    it "calls the correct wrapper method" do
      synonym = create(:synonym)

      expect(ElasticsearchWrapper::Synonyms).to receive(:add).with(
        rule_id: synonym.id,
        value: synonym.to_elasticsearch_value
      )

      synonym.add_to_elastic_search_synonyms
    end
  end

  describe "#remove_from_elastic_search_synonyms" do
    it "calls the correct wrapper method" do
      synonym = create(:synonym)

      expect(ElasticsearchWrapper::Synonyms).to receive(:remove).with(
        rule_id: synonym.id,
      )

      synonym.remove_from_elastic_search_synonyms
    end
  end
end
