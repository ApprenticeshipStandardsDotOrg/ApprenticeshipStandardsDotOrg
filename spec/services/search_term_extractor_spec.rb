require "rails_helper"

RSpec.describe SearchTermExtractor do
  describe "#call" do
    context "when query param is not present" do
      it "returns same params" do
        params = {
          state_id: "2"
        }

        result = described_class.call(params)

        expect(result).to eq({
          state_id: "2"
        })
      end
    end

    context "when there is no match" do
      it "returns same params" do
        params = {
          q: "Sample",
          state: "CA",
          ojt_type: "hybrid",
          national_standard_type: "guideline_standard"
        }

        result = described_class.call(params)

        expect(result).to eq({
          q: "Sample",
          state: "CA",
          ojt_type: "hybrid",
          national_standard_type: "guideline_standard"
        })
      end
    end

    it "extracts the state when present" do
      params = {
        q: "Sample state:ca"
      }

      result = described_class.call(params)

      expect(result).to eq({
        q: "Sample",
        state: "ca"
      })
    end

    it "extracts the ojt_type when present" do
      params = {
        q: "Sample ojt_type:competency"
      }

      result = described_class.call(params)

      expect(result).to eq({
        q: "Sample",
        ojt_type: {competency: 1}
      })
    end

    it "extracts the national_standard_type when present" do
      params = {
        q: "Sample national_standard_type:occupational_framework"
      }

      result = described_class.call(params)

      expect(result).to eq({
        q: "Sample",
        national_standard_type: {occupational_framework: 1}
      })
    end

    it "extracts multiple values" do
      params = {
        q: "state:ca Sample Search national_standard_type:occupational_framework ojt_type:time"
      }

      result = described_class.call(params)

      expect(result).to eq({
        q: "Sample Search",
        national_standard_type: {occupational_framework: 1},
        ojt_type: {time: 1},
        state: "ca"
      })
    end
  end
end
