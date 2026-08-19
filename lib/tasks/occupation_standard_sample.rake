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
    limit = ENV["COUNT"].to_i
    pdfs = sample_source_pdfs_without_ai_conversion
    pdfs = pdfs.limit(limit) if limit.positive?

    puts "Dry run: #{dry_run}"
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

  def sample_source_pdfs_without_ai_conversion
    Imports::Pdf
      .joins(:data_imports)
      .joins(:file_attachment)
      .left_outer_joins(:open_ai_import)
      .where(data_imports: {occupation_standard_id: OccupationStandard.where(sample_set: true).select(:id)})
      .where(open_ai_imports: {id: nil})
      .distinct
  end

  def source_pdf_ai_conversion_count(scope)
    OpenAIImport
      .joins("INNER JOIN data_imports ON data_imports.import_id = open_ai_imports.import_id")
      .where(data_imports: {occupation_standard_id: scope.select(:id)})
      .distinct
      .count
  end
end
