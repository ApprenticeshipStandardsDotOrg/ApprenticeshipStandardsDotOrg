namespace :ai_imports do
  desc "Convert unprocessed PDF imports with AI. Usage: bin/rails 'ai_imports:convert[10,source-filter]'"
  task :convert, [:count, :source] => :environment do |_task, args|
    count = args[:count].presence || ENV["COUNT"]
    source = args[:source].presence || ENV["SOURCE"]

    unless count.to_i.positive?
      abort "COUNT is required. Usage: bin/rails 'ai_imports:convert[10]' or COUNT=10 bin/rails ai_imports:convert"
    end

    converted = 0
    skipped = 0
    attempted = 0
    limit = count.to_i

    pdfs_without_ai_conversion_candidates.find_each do |pdf|
      next unless source_match?(pdf, source)

      attempted += 1
      result = ConvertPdfImportWithAI.new(import: pdf).call

      if result.created
        converted += 1
        puts "Converted #{pdf.id} -> #{result.occupation_standard.id}"
      else
        skipped += 1
        puts "Skipped #{pdf.id}: #{result.errors.join(", ")}"
      end

      break if attempted >= limit
    end

    puts "AI import conversion complete. Attempted: #{attempted}. Converted: #{converted}. Skipped: #{skipped}."
  end

  def pdfs_without_ai_conversion_candidates
    Imports::Pdf
      .left_outer_joins(:open_ai_import)
      .where(open_ai_imports: {id: nil})
      .without_occupation_standard
      .includes(:open_ai_import, :parent, file_attachment: :blob)
      .order(:created_at)
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
