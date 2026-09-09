require "rails_helper"

Rails.application.load_tasks unless Rake::Task.task_defined?("occupation_standards:export")

RSpec.describe "occupation_standards:export" do
  before do
    Rake::Task["occupation_standards:export"].reenable
    Rake::Task["occupation_standards:enqueue_targeted_ai_conversions"].reenable
  end

  after { ENV.delete("SOC_CODES") }

  it "writes the export to the provided path" do
    occupation_standard = create(:occupation_standard, onet_code: "29-2034.00")
    create(:occupation_standard, onet_code: "29-1141.00")
    path = Rails.root.join("tmp", "occupation-standard-export-spec.csv")

    Rake::Task["occupation_standards:export"].invoke(path.to_s)

    report = CSV.read(path, headers: true)
    expect(report.length).to eq 1
    expect(report.first["name"]).to eq occupation_standard.title
  ensure
    FileUtils.rm_f(path)
  end

  it "allows the target SOC codes to be overridden" do
    occupation_standard = create(:occupation_standard, onet_code: "29-1141.00")
    path = Rails.root.join("tmp", "occupation-standard-custom-export-spec.csv")
    ENV["SOC_CODES"] = "29-1141"

    Rake::Task["occupation_standards:export"].invoke(path.to_s)

    report = CSV.read(path, headers: true)
    expect(report.map { |row| row["name"] }).to eq [occupation_standard.title]
  ensure
    FileUtils.rm_f(path)
  end

  it "enqueues each matching source PDF without an existing AI conversion" do
    open_ai_prompt = create(:open_ai_prompt, default: true)
    matching_standard = create(:occupation_standard, onet_code: "29-2034.00")
    matching_pdf = create(:imports_pdf)
    create(:data_import, import: matching_pdf, occupation_standard: matching_standard)

    converted_standard = create(:occupation_standard, onet_code: "29-2034.00")
    converted_pdf = create(:imports_pdf)
    create(:data_import, import: converted_pdf, occupation_standard: converted_standard)
    create(:open_ai_import, import: converted_pdf)

    allow(PdfReaderJob).to receive(:perform_later)

    Rake::Task["occupation_standards:enqueue_targeted_ai_conversions"].invoke

    expect(PdfReaderJob).to have_received(:perform_later).once.with(
      import_id: matching_pdf.id,
      open_ai_prompt: open_ai_prompt,
      force: false
    )
  end
end
