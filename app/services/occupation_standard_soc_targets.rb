class OccupationStandardSocTargets
  CODES = %w[
    11-3021
    11-3051
    11-3071
    11-9081
    11-9161
    13-1081
    13-1121
    13-2011
    15-2031
    17-2061
    17-2112
    17-3011
    27-4011
    29-1126
    29-2034
    29-2052
    29-2061
    33-2011
    47-2152
    51-2041
  ].freeze

  SOC_CODE_PATTERN = /\A\d{2}-\d{4}\z/

  def self.from_environment
    configured_codes = ENV["SOC_CODES"].to_s.split(/[\s,]+/).compact_blank
    new(codes: configured_codes.presence || CODES)
  end

  def initialize(codes: CODES)
    @codes = codes.map(&:to_s).map(&:strip).uniq.sort

    invalid_codes = @codes.reject { |code| code.match?(SOC_CODE_PATTERN) }
    raise ArgumentError, "Invalid SOC codes: #{invalid_codes.join(", ")}" if invalid_codes.any?
  end

  attr_reader :codes

  def occupation_standards
    OccupationStandard.where(<<~SQL.squish, codes: codes)
      REGEXP_REPLACE(occupation_standards.onet_code, '\\.[0-9]+$', '') IN (:codes)
    SQL
  end

  def source_pdfs
    Imports::Pdf
      .joins(:file_attachment)
      .where(id: DataImport.where(occupation_standard_id: occupation_standards.select(:id)).select(:import_id))
      .distinct
  end

  def source_pdfs_without_ai_conversion
    source_pdfs
      .left_outer_joins(:open_ai_import)
      .where(open_ai_imports: {id: nil})
  end
end
