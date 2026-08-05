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

  it "counts only successful conversions toward the requested count" do
    skipped_pdf = create(:imports_pdf, created_at: 2.days.ago)
    converted_pdf = create(:imports_pdf, created_at: 1.day.ago)

    skipped_converter = instance_double(
      ConvertPdfImportWithAI,
      call: ConvertPdfImportWithAI::Result.new(
        open_ai_import: nil,
        occupation_standard: nil,
        created: false,
        errors: ["Could not extract title"]
      )
    )
    converted_converter = instance_double(
      ConvertPdfImportWithAI,
      call: ConvertPdfImportWithAI::Result.new(
        open_ai_import: nil,
        occupation_standard: create(:occupation_standard),
        created: true,
        errors: []
      )
    )

    allow(ConvertPdfImportWithAI).to receive(:new).with(import: skipped_pdf).and_return(skipped_converter)
    allow(ConvertPdfImportWithAI).to receive(:new).with(import: converted_pdf).and_return(converted_converter)

    Rake::Task["ai_imports:convert"].invoke("1")

    expect(ConvertPdfImportWithAI).to have_received(:new).with(import: skipped_pdf).once
    expect(ConvertPdfImportWithAI).to have_received(:new).with(import: converted_pdf).once
  end

  it "marks skipped PDFs by default so they are not candidates for future runs" do
    skipped_pdf = create(:imports_pdf)

    allow(ConvertPdfImportWithAI).to receive(:new).and_return(
      instance_double(
        ConvertPdfImportWithAI,
        call: ConvertPdfImportWithAI::Result.new(
          open_ai_import: nil,
          occupation_standard: nil,
          created: false,
          errors: ["Could not read PDF"]
        )
      )
    )

    Rake::Task["ai_imports:convert"].invoke("1")

    expect(skipped_pdf.reload).to be_needs_backend_support
    expect(skipped_pdf.processing_errors).to eq "AI conversion skipped: Could not read PDF"

    Rake::Task["ai_imports:convert"].reenable
    Rake::Task["ai_imports:convert"].invoke("1")

    expect(ConvertPdfImportWithAI).to have_received(:new).once
  end

  it "does not mark skipped PDFs when explicitly disabled" do
    skipped_pdf = create(:imports_pdf)

    allow(ConvertPdfImportWithAI).to receive(:new).and_return(
      instance_double(
        ConvertPdfImportWithAI,
        call: ConvertPdfImportWithAI::Result.new(
          open_ai_import: nil,
          occupation_standard: nil,
          created: false,
          errors: ["Could not read PDF"]
        )
      )
    )

    Rake::Task["ai_imports:convert"].invoke("1", nil, "false")

    expect(skipped_pdf.reload).to be_pending
    expect(skipped_pdf.processing_errors).to be_nil
  end
end
