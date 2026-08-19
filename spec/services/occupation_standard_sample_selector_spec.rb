require "rails_helper"

RSpec.describe OccupationStandardSampleSelector do
  describe "#call" do
    it "marks a sample set from occupation standards with work processes and source PDFs" do
      create(:occupation_standard, sample_set: true)
      eligible = create_list(:occupation_standard, 2, :with_work_processes, rapids_code: "1234")
      eligible.each { |occupation_standard| create(:data_import, occupation_standard: occupation_standard) }
      create(:occupation_standard, :with_work_processes, rapids_code: "9999")

      result = described_class.new(sample_size: 2, seed: "test").call

      expect(result.selected_count).to eq 2
      expect(OccupationStandard.where(sample_set: true)).to match_array eligible
    end

    it "excludes occupation standards without a source PDF import" do
      missing_pdf = create(:occupation_standard, :with_work_processes, rapids_code: "1234")
      eligible = create(:occupation_standard, :with_work_processes, rapids_code: "1234")
      create(:data_import, occupation_standard: eligible)

      described_class.new(sample_size: 2, seed: "test").call

      expect(OccupationStandard.where(sample_set: true)).to contain_exactly eligible
      expect(missing_pdf.reload.sample_set).to be false
    end

    it "excludes occupation standards with AI conversion on their source PDF" do
      converted_source = create(:occupation_standard, :with_work_processes, rapids_code: "1234")
      converted_import = create(:imports_pdf)
      create(:data_import, import: converted_import, occupation_standard: converted_source)
      create(:open_ai_import, import: converted_import)
      eligible = create(:occupation_standard, :with_work_processes, rapids_code: "1234")
      create(:data_import, occupation_standard: eligible)

      described_class.new(sample_size: 2, seed: "test").call

      expect(OccupationStandard.where(sample_set: true)).to contain_exactly eligible
      expect(converted_source.reload.sample_set).to be false
    end

    it "includes inferred manual conversions before filling the rest of the sample set" do
      standards_import = create(
        :standards_import,
        courtesy_notification: :completed,
        email: "uploader@example.com",
        name: "Uploader"
      )
      import = create(:imports_pdf, parent: standards_import)
      manual_standard = create(:occupation_standard, :with_work_processes)
      create(:data_import, import: import, occupation_standard: manual_standard)
      filler_standard = create(:occupation_standard, :with_work_processes, rapids_code: "1234")
      create(:data_import, occupation_standard: filler_standard)

      result = described_class.new(sample_size: 1, seed: "test").call

      expect(result.manual_ids).to contain_exactly manual_standard.id
      expect(OccupationStandard.where(sample_set: true)).to contain_exactly manual_standard
    end

    it "supports explicit manual occupation standard ids" do
      manual_standard = create(:occupation_standard, :with_work_processes)
      create(:data_import, occupation_standard: manual_standard)
      filler_standard = create(:occupation_standard, :with_work_processes, rapids_code: "1234")
      create(:data_import, occupation_standard: filler_standard)

      described_class.new(sample_size: 1, manual_ids: [manual_standard.id], seed: "test").call

      expect(OccupationStandard.where(sample_set: true)).to contain_exactly manual_standard
    end
  end
end
