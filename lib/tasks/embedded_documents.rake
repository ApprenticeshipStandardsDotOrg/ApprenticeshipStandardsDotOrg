namespace :documents do
  desc "Audit Word-derived PDFs linked to standards; writes document payloads and report under tmp"
  task audit_embedded: :environment do
    require "digest"
    directory = Rails.root.join("tmp/embedded-document-audit")
    FileUtils.mkdir_p(directory)
    scope = Imports::Pdf.with_occupation_standard.where(
      parent_type: "Import", parent_id: Import.where(type: ["Imports::Doc", "Imports::Docx"]).select(:id)
    )
    scope = scope.where(id: ENV.fetch("PDF_IDS").split(",")) if ENV["PDF_IDS"].present?
    scope = scope.includes(:data_import_occupation_standards,
      open_ai_import: :occupation_standard,
      file_attachment: :blob, parent: {file_attachment: :blob})
    counts = Hash.new(0)
    File.open(directory.join("report.jsonl"), "w") do |report|
      scope.find_each do |pdf|
        row = {pdf_id: pdf.id, parent_id: pdf.parent_id}
        begin
          source = pdf.parent
          folder = directory.join(pdf.id)
          FileUtils.mkdir_p(folder)
          path = folder.join("source")
          File.binwrite(path, source.file.download)
          result = ExtractEmbeddedDocuments.call(path, directory: folder.join("extracted"))
          row.merge!(filename: source.filename, source_sha256: Digest::SHA256.file(path).hexdigest,
            paths: result.paths, unsupported: result.unsupported,
            standard_ids: pdf.associated_occupation_standards.map(&:id))
          counts[:embedded] += 1 if result.paths.any?
          counts[:unsupported] += 1 if result.unsupported.any?
        rescue => error
          row[:error] = "#{error.class}: #{error.message}"
          counts[:errors] += 1
        end
        counts[:audited] += 1
        report.puts(row.to_json)
      end
    end
    puts counts.to_json
    puts "Review payloads and current PDFs before preparing a repair manifest. Report: #{directory.join("report.jsonl")}"
  end

  desc "Apply a reviewed PDF replacement manifest. MANIFEST=tmp/repairs.json DRY_RUN=true (default)"
  task repair_embedded: :environment do
    manifest = JSON.parse(File.read(ENV.fetch("MANIFEST")))
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", "true"))
    manifest.each do |entry|
      result = RepairEmbeddedImportPdf.call(
        pdf: Imports::Pdf.find(entry.fetch("pdf_id")),
        replacement_path: entry.fetch("replacement_path"),
        source_sha256: entry.fetch("source_sha256"),
        original_sha256: entry.fetch("original_sha256"),
        replacement_sha256: entry.fetch("replacement_sha256"),
        dry_run: dry_run
      )
      puts({pdf_id: entry.fetch("pdf_id"), result: result}.to_json)
    end
  end

  desc "Remove backups from the earlier PDF repair. DRY_RUN=true (default)"
  task remove_repair_backups: :environment do
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", "true"))
    ids = ActiveStorage::Attachment.where(record_type: "Import", name: "file_before_embedded_repair").select(:record_id)
    Imports::Pdf.where(id: ids).find_each do |pdf|
      puts({pdf_id: pdf.id, result: RemoveEmbeddedPdfBackup.call(pdf: pdf, dry_run: dry_run)}.to_json)
    end
  end

  desc "Rerun prior AI attempts for repaired PDFs. DRY_RUN=true COUNT=1 (defaults)"
  task reconvert_repaired: :environment do
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", "true"))
    count = Integer(ENV.fetch("COUNT", "1"))
    abort "COUNT must be positive" unless count.positive?

    scope = Imports::Pdf.joins(:open_ai_import).where("imports.metadata ? 'embedded_document_repair'").distinct
    scope = scope.where(id: ENV.fetch("PDF_IDS").split(",")) if ENV["PDF_IDS"].present?
    attempted = 0
    succeeded = 0
    failed = 0
    scope.find_each(cursor: [:created_at, :id], order: [:asc, :asc]) do |pdf|
      repair = pdf.metadata.fetch("embedded_document_repair")
      next if repair["ai_conversion_sha256"] == repair["replacement_sha256"]

      attempted += 1
      begin
        if dry_run
          puts({pdf_id: pdf.id, standard_id: pdf.open_ai_import.occupation_standard_id, result: "would_reconvert"}.to_json)
        else
          result = ReconvertRepairedPdfWithAI.new(import: pdf).call
          result.created ? succeeded += 1 : failed += 1
          puts({pdf_id: pdf.id, standard_id: result.occupation_standard&.id, result: result.created ? "reconverted" : "needs_review", errors: result.errors}.to_json)
        end
      rescue => error
        failed += 1
        puts({pdf_id: pdf.id, result: "error", error: "#{error.class}: #{error.message}"}.to_json)
      end
      break if attempted >= count
    end
    puts({dry_run: dry_run, attempted: attempted, succeeded: succeeded, failed: failed}.to_json)
    abort "Some AI conversions need review; inspect the results before continuing" if failed.positive?
  end
end
