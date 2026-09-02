require "rails_helper"

Rails.application.load_tasks unless Rake::Task.task_defined?("occupation_standards:enqueue_sample_ai_conversions")

RSpec.describe "occupation_standards rake tasks" do
  before do
    Rake::Task["occupation_standards:enqueue_sample_ai_conversions"].reenable
    Rake::Task["occupation_standards:reset_sample_ai_conversions"].reenable
    Rake::Task["occupation_standards:sample_set_report"].reenable
  end

  after do
    ENV.delete("COUNT")
    ENV.delete("BASELINE_ONLY")
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

    it "limits enqueued jobs to the requested sample source PDF count" do
      create(:open_ai_prompt, default: true)
      first_standard = create(:occupation_standard, sample_set: true)
      first_import = create(:imports_pdf, id: "00000000-0000-0000-0000-000000000001")
      create(:data_import, import: first_import, occupation_standard: first_standard)
      second_standard = create(:occupation_standard, sample_set: true)
      second_import = create(:imports_pdf, id: "00000000-0000-0000-0000-000000000002")
      create(:data_import, import: second_import, occupation_standard: second_standard)
      ENV["COUNT"] = "1"

      allow(PdfReaderJob).to receive(:perform_later)

      Rake::Task["occupation_standards:enqueue_sample_ai_conversions"].invoke

      expect(PdfReaderJob).to have_received(:perform_later).once.with(
        import_id: first_import.id,
        open_ai_prompt: OpenAIPrompt.default,
        force: false
      )
    end

    it "can enqueue only OA state single-occupation sample source PDFs" do
      create(:open_ai_prompt, default: true)
      baseline_standard = create(:occupation_standard, sample_set: true, registration_agency: create(:registration_agency, agency_type: :oa))
      baseline_import = create(:imports_pdf, id: "00000000-0000-0000-0000-000000000001")
      create(:data_import, import: baseline_import, occupation_standard: baseline_standard)
      saa_standard = create(:occupation_standard, sample_set: true, registration_agency: create(:registration_agency, agency_type: :saa))
      saa_import = create(:imports_pdf, id: "00000000-0000-0000-0000-000000000002")
      create(:data_import, import: saa_import, occupation_standard: saa_standard)
      multi_standard = create(:occupation_standard, sample_set: true, registration_agency: create(:registration_agency, agency_type: :oa))
      multi_import = create(:imports_pdf, id: "00000000-0000-0000-0000-000000000003")
      create(:data_import, import: multi_import, occupation_standard: multi_standard)
      create(:data_import, import: multi_import, occupation_standard: create(:occupation_standard, sample_set: false))
      ENV["BASELINE_ONLY"] = "true"

      allow(PdfReaderJob).to receive(:perform_later)

      Rake::Task["occupation_standards:enqueue_sample_ai_conversions"].invoke

      expect(PdfReaderJob).to have_received(:perform_later).once.with(
        import_id: baseline_import.id,
        open_ai_prompt: OpenAIPrompt.default,
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

    it "limits reset to the requested sample source PDF count" do
      first_standard = create(:occupation_standard, sample_set: true)
      first_import = create(:imports_pdf, id: "00000000-0000-0000-0000-000000000001")
      create(:data_import, import: first_import, occupation_standard: first_standard)
      first_ai_standard = create(:occupation_standard, source: :ai_conversion)
      first_open_ai_import = create(:open_ai_import, import: first_import, occupation_standard: first_ai_standard)

      second_standard = create(:occupation_standard, sample_set: true)
      second_import = create(:imports_pdf, id: "00000000-0000-0000-0000-000000000002")
      create(:data_import, import: second_import, occupation_standard: second_standard)
      second_ai_standard = create(:occupation_standard, source: :ai_conversion)
      second_open_ai_import = create(:open_ai_import, import: second_import, occupation_standard: second_ai_standard)
      ENV["COUNT"] = "1"

      Rake::Task["occupation_standards:reset_sample_ai_conversions"].invoke

      expect(OpenAIImport.exists?(first_open_ai_import.id)).to be false
      expect(OccupationStandard.exists?(first_ai_standard.id)).to be false
      expect(OpenAIImport.exists?(second_open_ai_import.id)).to be true
      expect(OccupationStandard.exists?(second_ai_standard.id)).to be true
    end

    it "can reset only OA state single-occupation sample source PDFs" do
      baseline_standard = create(:occupation_standard, sample_set: true, registration_agency: create(:registration_agency, agency_type: :oa))
      baseline_import = create(:imports_pdf, id: "00000000-0000-0000-0000-000000000001")
      create(:data_import, import: baseline_import, occupation_standard: baseline_standard)
      baseline_ai_standard = create(:occupation_standard, source: :ai_conversion)
      baseline_open_ai_import = create(:open_ai_import, import: baseline_import, occupation_standard: baseline_ai_standard)

      saa_standard = create(:occupation_standard, sample_set: true, registration_agency: create(:registration_agency, agency_type: :saa))
      saa_import = create(:imports_pdf, id: "00000000-0000-0000-0000-000000000002")
      create(:data_import, import: saa_import, occupation_standard: saa_standard)
      saa_ai_standard = create(:occupation_standard, source: :ai_conversion)
      saa_open_ai_import = create(:open_ai_import, import: saa_import, occupation_standard: saa_ai_standard)
      ENV["BASELINE_ONLY"] = "true"

      Rake::Task["occupation_standards:reset_sample_ai_conversions"].invoke

      expect(OpenAIImport.exists?(baseline_open_ai_import.id)).to be false
      expect(OccupationStandard.exists?(baseline_ai_standard.id)).to be false
      expect(OpenAIImport.exists?(saa_open_ai_import.id)).to be true
      expect(OccupationStandard.exists?(saa_ai_standard.id)).to be true
    end
  end

  describe "occupation_standards:sample_set_report" do
    it "writes the sample set report to the provided path" do
      sample_standard = create(:occupation_standard, sample_set: true)
      create(:data_import, occupation_standard: sample_standard)
      create(:occupation_standard, sample_set: false)
      path = Rails.root.join("tmp", "sample-set-report-spec.csv")

      Rake::Task["occupation_standards:sample_set_report"].invoke(path.to_s)

      report = CSV.read(path, headers: true)
      expect(report.length).to eq 1
      expect(report.first["id"]).to eq sample_standard.id
    ensure
      FileUtils.rm_f(path)
    end

    it "limits the report to occupation standards linked to the requested sample source PDF count" do
      first_standard = create(:occupation_standard, sample_set: true)
      first_import = create(:imports_pdf, id: "00000000-0000-0000-0000-000000000001")
      create(:data_import, import: first_import, occupation_standard: first_standard)
      second_standard = create(:occupation_standard, sample_set: true)
      second_import = create(:imports_pdf, id: "00000000-0000-0000-0000-000000000002")
      create(:data_import, import: second_import, occupation_standard: second_standard)
      path = Rails.root.join("tmp", "sample-set-report-count-spec.csv")
      ENV["COUNT"] = "1"

      Rake::Task["occupation_standards:sample_set_report"].invoke(path.to_s)

      report = CSV.read(path, headers: true)
      expect(report.length).to eq 1
      expect(report.first["id"]).to eq first_standard.id
    ensure
      FileUtils.rm_f(path)
    end

    it "can report only OA state single-occupation sample standards" do
      baseline_standard = create(:occupation_standard, sample_set: true, registration_agency: create(:registration_agency, agency_type: :oa))
      baseline_import = create(:imports_pdf, id: "00000000-0000-0000-0000-000000000001")
      create(:data_import, import: baseline_import, occupation_standard: baseline_standard)
      saa_standard = create(:occupation_standard, sample_set: true, registration_agency: create(:registration_agency, agency_type: :saa))
      saa_import = create(:imports_pdf, id: "00000000-0000-0000-0000-000000000002")
      create(:data_import, import: saa_import, occupation_standard: saa_standard)
      path = Rails.root.join("tmp", "sample-set-report-baseline-spec.csv")
      ENV["BASELINE_ONLY"] = "true"

      Rake::Task["occupation_standards:sample_set_report"].invoke(path.to_s)

      report = CSV.read(path, headers: true)
      expect(report.length).to eq 1
      expect(report.first["id"]).to eq baseline_standard.id
    ensure
      FileUtils.rm_f(path)
    end

    it "writes the sample set report to stdout" do
      sample_standard = create(:occupation_standard, sample_set: true)
      create(:data_import, occupation_standard: sample_standard)
      create(:occupation_standard, sample_set: false)

      expect {
        Rake::Task["occupation_standards:sample_set_report"].invoke("-")
      }.to output(include(sample_standard.id)).to_stdout
    end
  end
end
