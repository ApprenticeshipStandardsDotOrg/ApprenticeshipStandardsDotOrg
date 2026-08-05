namespace :ai_imports do
  desc "Convert unprocessed PDF imports with AI. Usage: bin/rails 'ai_imports:convert[10,source-filter]'"
  task :convert, [:count, :source, :mark_skipped] => :environment do |_task, args|
    count = args[:count].presence || ENV["COUNT"]
    source = args[:source].presence || ENV["SOURCE"]
    mark_skipped = mark_skipped?(args[:mark_skipped])

    unless count.to_i.positive?
      abort "COUNT is required. Usage: bin/rails 'ai_imports:convert[10]' or COUNT=10 bin/rails ai_imports:convert"
    end

    converted = 0
    skipped = 0
    attempted = 0
    limit = count.to_i

    pdfs_without_ai_conversion_candidates.find_each(cursor: [:created_at, :id], order: [:asc, :asc]) do |pdf|
      next unless source_match?(pdf, source)

      attempted += 1
      result = convert_pdf(pdf)

      if result.created
        converted += 1
        puts "Converted #{pdf.id} -> #{result.occupation_standard.id}"
      else
        skipped += 1
        errors = result.errors.join(", ")
        mark_skipped_pdf(pdf, errors) if mark_skipped
        puts "Skipped #{pdf.id}: #{errors}"
      end

      break if converted >= limit
    end

    puts "AI import conversion complete. Attempted: #{attempted}. Converted: #{converted}. Skipped: #{skipped}."
  end

  def pdfs_without_ai_conversion_candidates
    Imports::Pdf
      .left_outer_joins(:open_ai_import)
      .where(open_ai_imports: {id: nil})
      .where.not(status: :needs_backend_support)
      .without_occupation_standard
      .includes(:open_ai_import, :parent, file_attachment: :blob)
  end

  def convert_pdf(pdf)
    ConvertPdfImportWithAI.new(import: pdf).call
  rescue => error
    ConvertPdfImportWithAI::Result.new(
      open_ai_import: nil,
      occupation_standard: nil,
      created: false,
      errors: ["#{error.class}: #{error.message}"]
    )
  end

  def mark_skipped_pdf(pdf, errors)
    pdf.update!(
      status: :needs_backend_support,
      processing_errors: "AI conversion skipped: #{errors}"
    )
  end

  def mark_skipped?(argument)
    value = argument.presence || ENV["MARK_SKIPPED"]
    return true if value.blank?

    ActiveModel::Type::Boolean.new.cast(value)
  end

  def source_match?(pdf, source)
    return true if source.blank?

    source = source.downcase
    root = pdf.import_root
    values = [
      pdf.type,
      pdf.parent_type,
      pdf.metadata,
      root.try(:name),
      root.try(:organization),
      root.try(:source_url),
      root.try(:metadata)
    ]

    values.compact.any? { |value| value.to_s.downcase.include?(source) }
  end
end
