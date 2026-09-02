namespace :occupation_standards do
  desc "Select the occupation standards sample set. Usage: SAMPLE_SIZE=500 SAMPLE_SEED=2026-08-19 bin/rails occupation_standards:select_sample"
  task :select_sample, [:count] => :environment do |_task, args|
    result = OccupationStandardSampleSelector.new(
      sample_size: (args[:count].presence || ENV.fetch("SAMPLE_SIZE", OccupationStandardSampleSelector::DEFAULT_SAMPLE_SIZE)).to_i
    ).call
    scope = OccupationStandard.where(id: result.selected_ids)
    ojt_type_counts = scope.group(:ojt_type).count.transform_keys do |key|
      key.is_a?(Integer) ? OccupationStandard.ojt_types.key(key) : key
    end

    puts "Selected #{result.selected_count} occupation standards for the sample"
    puts "Dry run: #{result.dry_run}"
    puts "Manual conversions included: #{result.manual_ids.count}"
    puts "With source PDF imports: #{scope.joins(data_imports: {import: :file_attachment}).distinct.count}"
    puts "With direct AI conversions: #{scope.joins(:open_ai_import).distinct.count}"
    puts "With source PDF AI conversions: #{source_pdf_ai_conversion_count(scope)}"
    puts "RAPIDS records: #{scope.where.not(rapids_code: [nil, ""]).count}"
    puts "OJT type counts: #{ojt_type_counts}"

    OccupationStandardSampleSelector::STATE_ABBREVIATIONS.each do |abbreviation|
      puts "#{abbreviation} records: #{scope.by_state_abbreviation(abbreviation).count}"
    end
  end

  desc "Enqueue AI conversion jobs for selected sample set source PDFs. Usage: bin/rails occupation_standards:enqueue_sample_ai_conversions"
  task enqueue_sample_ai_conversions: :environment do
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", false))
    pdfs = sample_source_pdfs_without_ai_conversion

    puts "Dry run: #{dry_run}"
    puts "Baseline only: #{baseline_only?}"
    puts "Source PDF subset size: #{sample_source_pdf_ids.count}"
    puts "Source PDFs pending AI conversion: #{pdfs.count}"

    pdfs.find_each do |pdf|
      if dry_run
        puts "Would enqueue #{pdf.id}"
      else
        PdfReaderJob.perform_later(
          import_id: pdf.id,
          open_ai_prompt: OpenAIPrompt.default,
          force: false
        )
        puts "Enqueued #{pdf.id}"
      end
    end
  end

  desc "Delete AI conversions created from selected sample set source PDFs. Usage: bin/rails occupation_standards:reset_sample_ai_conversions"
  task reset_sample_ai_conversions: :environment do
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", false))
    open_ai_imports = sample_source_pdf_ai_conversions.includes(:occupation_standard)
    occupation_standards = open_ai_imports.filter_map(&:occupation_standard).uniq

    puts "Dry run: #{dry_run}"
    puts "Baseline only: #{baseline_only?}"
    puts "Source PDF subset size: #{sample_source_pdf_ids.count}"
    puts "Sample source PDF AI imports to delete: #{open_ai_imports.count}"
    puts "AI occupation standards to delete: #{occupation_standards.count}"

    next if dry_run

    open_ai_imports.find_each do |open_ai_import|
      OpenAIImport.transaction do
        occupation_standard = open_ai_import.occupation_standard
        import = open_ai_import.import

        open_ai_import.destroy!
        destroy_ai_occupation_standard(occupation_standard)
        import.pending! if import.archived?

        puts "Deleted AI conversion for import #{import.id}"
      end
    end
  end

  desc "Write the sample set comparison CSV report. Usage: bin/rails 'occupation_standards:sample_set_report[tmp/sample-report.csv]' or bin/rails 'occupation_standards:sample_set_report[-]'"
  task :sample_set_report, [:path] => :environment do |_task, args|
    path = args[:path].presence || Rails.root.join("tmp", "occupation-standards-sample-set-report-#{Time.zone.today}.csv")
    scope = sample_occupation_standards
    csv = OccupationStandardSampleSetReport.new(scope, filters: "sample_set:true").to_csv

    if path.to_s == "-"
      print csv
    else
      File.write(path, csv)

      puts "Wrote #{scope.count} sample set rows to #{path}"
    end
  end

  def sample_source_pdfs_without_ai_conversion
    Imports::Pdf
      .where(id: sample_source_pdf_ids)
      .left_outer_joins(:open_ai_import)
      .where(open_ai_imports: {id: nil})
      .order(:id)
  end

  def sample_source_pdf_ai_conversions
    OpenAIImport.where(id: sample_source_pdf_ai_conversion_ids)
  end

  def sample_source_pdf_ai_conversion_ids
    OpenAIImport
      .where(import_id: sample_source_pdf_ids)
      .select(:id)
      .distinct
  end

  def sample_occupation_standards
    query = OccupationStandard
      .where(sample_set: true)
      .joins(:data_imports)
      .where(data_imports: {import_id: sample_source_pdf_ids})
      .distinct

    query = query.where(id: baseline_standard_ids) if baseline_only?
    query
  end

  def sample_source_pdf_ids
    query = Imports::Pdf
      .joins(:data_imports)
      .joins(:file_attachment)
      .where(data_imports: {occupation_standard_id: OccupationStandard.where(sample_set: true).select(:id)})
      .select(:id)
      .distinct
      .order(:id)
    query = query.where(id: baseline_source_pdf_ids) if baseline_only?

    limit = ENV["COUNT"].to_i
    limit.positive? ? query.limit(limit) : query
  end

  def baseline_source_pdf_ids
    single_standard_source_pdf_ids = DataImport
      .where.not(occupation_standard_id: nil)
      .where.not(import_id: nil)
      .group(:import_id)
      .having("COUNT(DISTINCT occupation_standard_id) = 1")
      .select(:import_id)

    DataImport
      .where(occupation_standard_id: baseline_standard_ids)
      .where(import_id: single_standard_source_pdf_ids)
      .select(:import_id)
  end

  def baseline_standard_ids
    OccupationStandard
      .where(sample_set: true)
      .joins(:registration_agency)
      .where(registration_agencies: {agency_type: :oa})
      .where.not(registration_agencies: {state_id: nil})
      .select(:id)
  end

  def baseline_only?
    ActiveModel::Type::Boolean.new.cast(ENV.fetch("BASELINE_ONLY", false))
  end

  def destroy_ai_occupation_standard(occupation_standard)
    occupation_standard&.destroy!
  rescue Elastic::Transport::Transport::Errors::NotFound => error
    puts "Deleted AI occupation standard #{occupation_standard.id}; Elasticsearch document was already missing: #{error.message}"
  end

  def source_pdf_ai_conversion_count(scope)
    sample_source_pdf_ai_conversions
      .where(data_imports: {occupation_standard_id: scope.select(:id)})
      .count
  end
end
