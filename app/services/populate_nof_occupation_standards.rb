require "csv"
require "cgi"
require "open-uri"

class PopulateNofOccupationStandards
  Result = Data.define(:entries)

  def self.call(nofs_source:, bulletins_source:, dry_run: false)
    new(nofs_source:, bulletins_source:, dry_run:).call
  end

  def initialize(nofs_source:, bulletins_source:, dry_run:)
    @nofs_source = nofs_source
    @bulletins_source = bulletins_source
    @dry_run = dry_run
  end

  def call
    bulletins = csv_rows(bulletins_source).index_by { |row| bulletin_number(row["ID"]) }
    entries = csv_rows(nofs_source).map { |row| process(row, bulletins) }
    Result.new(entries:)
  end

  private

  attr_reader :nofs_source, :bulletins_source, :dry_run

  def process(row, bulletins)
    occupation = row["Occupation"].to_s.strip
    bulletin = bulletin_number(row["Bulletin"])
    if bulletin.blank?
      if title_match(OccupationStandard.where.not(title: [nil, ""]), occupation, minimum_score: 0.7)
        return entry(row, "already_populated", "A matching occupation standard exists; no bulletin was provided")
      end

      return entry(row, "missing_bulletin", "No bulletin number was provided")
    end

    roots = standards_imports_for(bulletin)
    linked_standards = occupation_standards_for(roots)
    if title_match(linked_standards, occupation)
      return entry(row, "already_populated", "A matching occupation standard is already linked")
    end

    if roots.empty?
      bulletin_row = bulletins[bulletin]
      if bulletin_row.blank?
        return entry(row, "missing_bulletin_result", "#{bulletin} was not present in the bulletin export")
      end

      file_uri = bulletin_row["File URI"].to_s.strip
      return entry(row, "missing_file_uri", "#{bulletin} does not provide a file URI") if file_uri.blank?
      return entry(row, "would_create_import", file_uri) if dry_run

      create_import(bulletin, bulletin_row, file_uri)
      roots = standards_imports_for(bulletin)
    end

    pdfs = pdfs_for(roots)
    if pdfs.empty?
      bulletin_row = bulletins[bulletin]
      if bulletin_row.blank?
        return entry(row, "no_pdf", "The existing bulletin import has no PDF leaves and no export source is available")
      end

      file_uri = bulletin_row["File URI"].to_s.strip
      return entry(row, "missing_file_uri", "#{bulletin} does not provide a file URI") if file_uri.blank?
      return entry(row, "would_reimport", file_uri) if dry_run

      create_import(bulletin, bulletin_row, file_uri)
      pdfs = pdfs_for(standards_imports_for(bulletin))
      return entry(row, "no_pdf", "Reimporting the bulletin did not produce a PDF leaf") if pdfs.empty?
    end

    eligible_pdfs = pdfs.reject { |pdf| pdf.open_ai_import&.occupation_standard_id.present? }
    if eligible_pdfs.empty?
      return entry(
        row,
        "title_mismatch",
        "Converted source PDFs exist, but none of their occupation-standard titles match #{occupation.inspect}"
      )
    end

    if dry_run
      return entry(row, "would_enqueue", "Would enqueue #{eligible_pdfs.length} source PDF(s)")
    end

    eligible_pdfs.each do |pdf|
      PdfReaderJob.perform_later(
        import_id: pdf.id,
        open_ai_prompt: OpenAIPrompt.default,
        force: pdf.open_ai_import.present?
      )
    end
    entry(row, "enqueued", "Enqueued #{eligible_pdfs.length} source PDF(s)")
  rescue => error
    entry(row, "error", "#{error.class}: #{error.message}")
  end

  def standards_imports_for(bulletin)
    StandardsImport.where("name ILIKE ?", "%#{StandardsImport.sanitize_sql_like(bulletin)}%").select do |root|
      bulletin_number(CGI.unescape(root.name)) == bulletin
    end
  end

  def occupation_standards_for(roots)
    import_ids = roots.flat_map { |root| descendant_ids(root) }
    ids = DataImport.where(import_id: import_ids).where.not(occupation_standard_id: nil).pluck(:occupation_standard_id)
    ids.concat(OpenAIImport.where(import_id: import_ids).where.not(occupation_standard_id: nil).pluck(:occupation_standard_id))
    OccupationStandard.where(id: ids.uniq).to_a
  end

  def pdfs_for(roots)
    roots.sort_by(&:created_at).reverse_each do |root|
      pdfs = Imports::Pdf.where(id: descendant_ids(root)).includes(:open_ai_import).to_a
      return pdfs if pdfs.any?
    end

    []
  end

  def descendant_ids(root)
    ids = []
    frontier = Import.where(parent: root).pluck(:id)

    while frontier.any?
      ids.concat(frontier)
      frontier = Import.where(parent_type: "Import", parent_id: frontier).pluck(:id)
    end

    ids
  end

  def title_match(standards, occupation, minimum_score: 0.35)
    standards.detect { |standard| title_score(occupation, standard.title) >= minimum_score }
  end

  def create_import(bulletin, bulletin_row, file_uri)
    CreateImportFromUri.call(
      uri: file_uri,
      title: bulletin_row["Subject"].presence || bulletin,
      notes: "From nofs:populate (#{bulletin})",
      source: Scraper::ApprenticeshipBulletinsJob::BULLETIN_LIST_URL,
      metadata: {date: bulletin_row["Date"]},
      listing: true
    )
  end

  def title_score(left, right)
    left_tokens = normalized_title(left).split.uniq
    right_tokens = normalized_title(right).split.uniq
    return 1.0 if left_tokens == right_tokens
    return 0.0 if left_tokens.empty? || right_tokens.empty?

    (2.0 * (left_tokens & right_tokens).length) / (left_tokens.length + right_tokens.length)
  end

  def normalized_title(value)
    value.to_s
      .downcase
      .gsub(/\([^)]*(?:cbof|update|spr)[^)]*\)/, " ")
      .gsub(/[^a-z0-9]+/, " ")
      .split
      .map { |word| (word.length > 4) ? word.sub(/s\z/, "") : word }
      .join(" ")
  end

  def bulletin_number(value)
    match = value.to_s.match(/\b(\d{4})-\s*(\d+)\b/)
    "#{match[1]}-#{match[2]}" if match
  end

  def csv_rows(source)
    contents = if source.match?(%r{\Ahttps?://})
      URI.parse(source).open.read
    else
      File.read(source)
    end
    CSV.parse(contents.sub(/\A\uFEFF/, ""), headers: true)
  end

  def entry(row, status, note)
    row.to_h.slice("Occupation", "Current Status", "Industry Sector", "Bulletin").merge(
      "Status" => status,
      "Summary" => note
    )
  end
end
