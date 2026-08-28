require "rails_helper"

Rails.application.load_tasks unless Rake::Task.task_defined?("occupation_standards:enqueue_sample_ai_conversions")

RSpec.describe "occupation_standards rake tasks" do
  before do
    Rake::Task["occupation_standards:enqueue_sample_ai_conversions"].reenable
    Rake::Task["occupation_standards:reset_sample_ai_conversions"].reenable
    Rake::Task["occupation_standards:sample_set_report"].reenable
  end

  describe "occupation_standards:enqueue_sample_ai_conversions" do
    it "enqueues conversion jobs for sample source PDFs without AI conversions" do
      open_ai_prompt = create(:open_ai_prompt, default: true)
      sample_standard = create(:occupation_standard, sample_set: true)
      sample_import = create(:imports_pdf)
      create(:data_import, import: sample_import, occupation_standard: sample_standard)

      already_converted_standard = create(:occupation_standard, sample_set: true)
      already_converted_import = create(:imports_pdf)
      create(:data_import, import: already_converted_import, occupation_standard: already_converted_standard)
      create(:open_ai_import, import: already_converted_import)

      non_sample_standard = create(:occupation_standard, sample_set: false)
      non_sample_import = create(:imports_pdf)
      create(:data_import, import: non_sample_import, occupation_standard: non_sample_standard)

      allow(PdfReaderJob).to receive(:perform_later)

      Rake::Task["occupation_standards:enqueue_sample_ai_conversions"].invoke

      expect(PdfReaderJob).to have_received(:perform_later).once.with(
        import_id: sample_import.id,
        open_ai_prompt: open_ai_prompt,
        force: false
      )
    end
  end

  describe "occupation_standards:reset_sample_ai_conversions" do
    it "deletes AI conversions for sample source PDFs without deleting the sample standards" do
      sample_standard = create(:occupation_standard, sample_set: true)
      sample_import = create(:imports_pdf, status: :archived)
      create(:data_import, import: sample_import, occupation_standard: sample_standard)
      ai_standard = create(:occupation_standard, source: :ai_conversion)
      open_ai_import = create(:open_ai_import, import: sample_import, occupation_standard: ai_standard)

      failed_sample_import = create(:imports_pdf)
      create(:data_import, import: failed_sample_import, occupation_standard: sample_standard)
      failed_open_ai_import = create(:open_ai_import, import: failed_sample_import, occupation_standard: nil)

      non_sample_standard = create(:occupation_standard, sample_set: false)
      non_sample_import = create(:imports_pdf, status: :archived)
      create(:data_import, import: non_sample_import, occupation_standard: non_sample_standard)
      non_sample_ai_standard = create(:occupation_standard, source: :ai_conversion)
      non_sample_open_ai_import = create(:open_ai_import, import: non_sample_import, occupation_standard: non_sample_ai_standard)

      Rake::Task["occupation_standards:reset_sample_ai_conversions"].invoke

      expect(OccupationStandard.exists?(sample_standard.id)).to be true
      expect(OccupationStandard.exists?(ai_standard.id)).to be false
      expect(OpenAIImport.exists?(open_ai_import.id)).to be false
      expect(OpenAIImport.exists?(failed_open_ai_import.id)).to be false
      expect(sample_import.reload).to be_pending
      expect(OccupationStandard.exists?(non_sample_ai_standard.id)).to be true
      expect(OpenAIImport.exists?(non_sample_open_ai_import.id)).to be true
      expect(non_sample_import.reload).to be_archived
    end
  end

  describe "occupation_standards:sample_set_report" do
    it "writes the sample set report to the provided path" do
      sample_standard = create(:occupation_standard, sample_set: true)
      create(:occupation_standard, sample_set: false)
      path = Rails.root.join("tmp", "sample-set-report-spec.csv")

      Rake::Task["occupation_standards:sample_set_report"].invoke(path.to_s)

      report = CSV.read(path, headers: true)
      expect(report.length).to eq 1
      expect(report.first["id"]).to eq sample_standard.id
    ensure
      FileUtils.rm_f(path)
    end
  end
end
