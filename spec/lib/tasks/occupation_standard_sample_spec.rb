require "rails_helper"

Rails.application.load_tasks unless Rake::Task.task_defined?("occupation_standards:enqueue_sample_ai_conversions")

RSpec.describe "occupation_standards rake tasks" do
  before do
    Rake::Task["occupation_standards:enqueue_sample_ai_conversions"].reenable
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
end
