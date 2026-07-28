require "rails_helper"

Rails.application.load_tasks unless Rake::Task.task_defined?("ai_imports:convert")

RSpec.describe "ai_imports:convert" do
  after do
    Rake::Task["ai_imports:convert"].reenable
  end

  it "only converts PDFs without an OpenAI import or associated occupation standard" do
    existing_standard_pdf = create(:imports_pdf)
    create(:data_import, import: existing_standard_pdf, occupation_standard: create(:occupation_standard))

    already_ai_converted_pdf = create(:imports_pdf)
    create(:open_ai_import, import: already_ai_converted_pdf)

    candidate_pdf = create(:imports_pdf)

    allow(ConvertPdfImportWithAI).to receive(:new).and_return(
      instance_double(
        ConvertPdfImportWithAI,
        call: ConvertPdfImportWithAI::Result.new(
          open_ai_import: nil,
          occupation_standard: create(:occupation_standard),
          created: true,
          errors: []
        )
      )
    )

    Rake::Task["ai_imports:convert"].invoke("10")

    expect(ConvertPdfImportWithAI).to have_received(:new).once.with(import: candidate_pdf)
  end
end
