require "csv"
require "digest"

class OccupationStandardOJTAuditReport < OccupationStandardSampleSetReport
  HEADERS = %w[id title source_pdf_occupation_scope baseline_ojt_type ai_ojt_type source_ojt_type classification reason evidence source_pdf_id ai_standard_id source_blob_id source_checksum text_sha256].freeze

  def initialize(relation, filters:)
    super
    @texts = {}
  end

  def to_csv
    CSV.generate do |csv|
      csv << HEADERS
      scope.find_each { |standard| csv << audit_row(standard) }
    end
  end

  private

  def audit_row(standard)
    attempt = open_ai_import_for(standard)
    actual = attempt&.occupation_standard
    source = attempt&.import
    text = source&.file&.attached? ? (@texts[source.id] ||= PdfTextExtractor.new(source.file).call) : ""
    response = attempt&.parsed_response || {}
    single = !standard.source_ai_conversion? && standard.source_pdf_occupation_scope == "single" &&
      response["documentOccupationCount"].to_i == 1 && response["singleOccupation"] != false &&
      Array(response["occupationInventory"]).size <= 1
    result = OJTTypeEvidence.new(text: text, single_occupation: single).call
    url = Rails.application.routes.url_helpers.admin_occupation_standard_url(standard, host: "admin.apprenticeshipstandards.org", protocol: "https")
    blob = source&.file&.blob
    [url, standard.title, standard.source_pdf_occupation_scope, standard.ojt_type, actual&.ojt_type,
      result.ojt_type, classification(standard, actual, result), result.reason, JSON.generate(result.evidence),
      source&.id, actual&.id, blob&.id, blob&.checksum, Digest::SHA256.hexdigest(text)]
  end

  def classification(standard, actual, result)
    return "missing_ai_conversion" unless actual
    return "needs_review" unless result.ojt_type

    baseline_matches = standard.ojt_type == result.ojt_type
    ai_matches = actual.ojt_type == result.ojt_type
    if baseline_matches && ai_matches
      "source_agreement"
    elsif ai_matches
      "baseline_source_conflict"
    elsif baseline_matches
      "ai_source_conflict"
    else
      "both_source_conflict"
    end
  end
end
