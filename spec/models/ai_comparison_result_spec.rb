require "rails_helper"

RSpec.describe AIComparisonResult, type: :model do
  it "has a valid factory" do
    comparison_result = build(:ai_comparison_result)

    expect(comparison_result).to be_valid
  end

  describe "associations" do
    it "belongs to occupation_standard" do
      comparison_result = build(:ai_comparison_result)
      expect(comparison_result.occupation_standard).to be_present
    end
  end

  describe "validations" do
    it "validates uniqueness of occupation_standard_id" do
      occupation_standard = create(:occupation_standard)
      create(:ai_comparison_result, occupation_standard: occupation_standard)
      duplicate_result = build(:ai_comparison_result, occupation_standard: occupation_standard)
      expect(duplicate_result).to_not be_valid
    end
  end

  describe "#flagged?" do
    context "when flagged_by_system is true" do
      it "returns true" do
        result = create(:ai_comparison_result, flagged_by_system: true, flagged_by_user: false)
        expect(result.flagged?).to be true
      end
    end

    context "when flagged_by_user is true" do
      it "returns true" do
        result = create(:ai_comparison_result, flagged_by_system: false, flagged_by_user: true)
        expect(result.flagged?).to be true
      end
    end

    context "when both are true" do
      it "returns true" do
        result = create(:ai_comparison_result, flagged_by_system: true, flagged_by_user: true)
        expect(result.flagged?).to be true
      end
    end

    context "when neither is true" do
      it "returns false" do
        result = create(:ai_comparison_result, flagged_by_system: false, flagged_by_user: false)
        expect(result.flagged?).to be false
      end
    end
  end

  describe "#update_review_status" do
    context "when overall_score is >= 70 and not flagged" do
      it "sets needs_review to false" do
        result = create(:ai_comparison_result, overall_score: 85.0, needs_review: true, flagged_by_system: false, flagged_by_user: false)
        result.update_review_status

        expect(result.needs_review).to be false
      end
    end

    context "when overall_score is < 70" do
      it "sets needs_review to true" do
        result = create(:ai_comparison_result, overall_score: 65.0, needs_review: false, flagged_by_system: true, flagged_by_user: false)
        result.update_review_status

        expect(result.needs_review).to be true
      end
    end

    context "when flagged_by_system is true" do
      it "sets needs_review to true" do
        result = create(:ai_comparison_result, overall_score: 85.0, needs_review: false, flagged_by_system: true, flagged_by_user: false)
        result.update_review_status

        expect(result.needs_review).to be true
      end
    end

    context "when flagged_by_user is true" do
      it "sets needs_review to true" do
        result = create(:ai_comparison_result, overall_score: 85.0, needs_review: false, flagged_by_system: false, flagged_by_user: true)
        result.update_review_status

        expect(result.needs_review).to be true
      end
    end

    context "when overall_score is nil" do
      it "does not change needs_review" do
        result = create(:ai_comparison_result, overall_score: nil, needs_review: false, flagged_by_system: false, flagged_by_user: false)
        original_status = result.needs_review
        result.update_review_status

        expect(result.needs_review).to eq(original_status)
      end
    end
  end

  describe ".needs_review" do
    it "returns only results that need review" do
      needs_review = create(:ai_comparison_result, needs_review: true)
      does_not_need_review = create(:ai_comparison_result, needs_review: false)

      expect(described_class.needs_review).to include(needs_review)
      expect(described_class.needs_review).not_to include(does_not_need_review)
    end
  end

  describe ".flagged" do
    it "returns results flagged by system or user" do
      flagged_by_system = create(:ai_comparison_result, flagged_by_system: true, flagged_by_user: false)
      flagged_by_user = create(:ai_comparison_result, flagged_by_system: false, flagged_by_user: true)
      both_flagged = create(:ai_comparison_result, flagged_by_system: true, flagged_by_user: true)
      not_flagged = create(:ai_comparison_result, flagged_by_system: false, flagged_by_user: false)

      flagged = described_class.flagged
      expect(flagged).to include(flagged_by_system)
      expect(flagged).to include(flagged_by_user)
      expect(flagged).to include(both_flagged)
      expect(flagged).not_to include(not_flagged)
    end
  end

  describe ".low_score" do
    it "returns results with overall_score below the threshold" do
      low_score = create(:ai_comparison_result, overall_score: 65.0)
      high_score = create(:ai_comparison_result, overall_score: 85.0)
      threshold_score = create(:ai_comparison_result, overall_score: 70.0)

      low_scores = described_class.low_score(70)
      expect(low_scores).to include(low_score)
      expect(low_scores).not_to include(high_score)
      expect(low_scores).not_to include(threshold_score)
    end

    it "uses default threshold of 70 when not specified" do
      low_score = create(:ai_comparison_result, overall_score: 65.0)
      high_score = create(:ai_comparison_result, overall_score: 85.0)

      low_scores = described_class.low_score
      expect(low_scores).to include(low_score)
      expect(low_scores).not_to include(high_score)
    end

    it "allows custom threshold" do
      score_60 = create(:ai_comparison_result, overall_score: 60.0)
      score_80 = create(:ai_comparison_result, overall_score: 80.0)

      low_scores = described_class.low_score(75)
      expect(low_scores).to include(score_60)
      expect(low_scores).not_to include(score_80)
    end
  end
end
