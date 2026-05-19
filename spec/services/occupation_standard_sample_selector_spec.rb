require "rails_helper"

RSpec.describe OccupationStandardSampleSelector do
  describe "#call" do
    it "marks a sample from occupation standards with work processes" do
      create(:occupation_standard, sample: true)
      eligible = create_list(:occupation_standard, 2, :with_work_processes, rapids_code: "1234")
      create(:occupation_standard, rapids_code: "9999")

      result = described_class.new(sample_size: 2, seed: "test").call

      expect(result.selected_count).to eq 2
      expect(OccupationStandard.where(sample: true)).to match_array eligible
    end

    it "includes inferred manual conversions before filling the rest of the sample" do
      standards_import = create(
        :standards_import,
        courtesy_notification: :completed,
        email: "uploader@example.com",
        name: "Uploader"
      )
      import = create(:imports_pdf, parent: standards_import)
      manual_standard = create(:occupation_standard, :with_work_processes)
      create(:data_import, import: import, occupation_standard: manual_standard)
      create(:occupation_standard, :with_work_processes, rapids_code: "1234")

      result = described_class.new(sample_size: 1, seed: "test").call

      expect(result.manual_ids).to contain_exactly manual_standard.id
      expect(OccupationStandard.where(sample: true)).to contain_exactly manual_standard
    end

    it "supports explicit manual occupation standard ids" do
      manual_standard = create(:occupation_standard, :with_work_processes)
      create(:occupation_standard, :with_work_processes, rapids_code: "1234")

      described_class.new(sample_size: 1, manual_ids: [manual_standard.id], seed: "test").call

      expect(OccupationStandard.where(sample: true)).to contain_exactly manual_standard
    end
  end
end
