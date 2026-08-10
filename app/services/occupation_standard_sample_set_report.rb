require "csv"

class OccupationStandardSampleSetReport
  HEADERS = %w[
    total
    filters
    pct_ojt_time
    pct_ojt_comp
    pct_ojt_hybrid
    pct_ojt_unknown
    pct_reg_agency
    pct_agency_oa
    pct_agency_saa
    pct_agency_unknown
    pct_org
    pct_source_manual
    pct_source_rapids
    pct_source_onet
    pct_source_ai
    pct_source_unknown
    pct_onet
    pct_rapids
    pct_work_proc
    avg_work_proc
    pct_rel_instr
    avg_rel_instr
  ].freeze

  def initialize(relation, filters:)
    @scope = OccupationStandard.where(id: relation.select(:id).distinct)
    @filters = filters
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << HEADERS
      csv << row
    end
  end

  private

  attr_reader :scope, :filters

  def row
    [
      total,
      filters.presence || "sample_set:true",
      percentage(ojt_type_counts["time"]),
      percentage(ojt_type_counts["competency"]),
      percentage(ojt_type_counts["hybrid"]),
      percentage(unknown_ojt_type_count),
      percentage(present_count(:registration_agency_id)),
      percentage(registration_agency_counts["oa"]),
      percentage(registration_agency_counts["saa"]),
      percentage(unknown_registration_agency_type_count),
      percentage(present_count(:organization_id)),
      percentage(source_counts["manual_upload"]),
      percentage(source_counts["rapids_api"]),
      percentage(source_counts["onet_api"]),
      percentage(source_counts["ai_conversion"]),
      percentage(unknown_source_count),
      percentage(present_text_count(:onet_code)),
      percentage(present_text_count(:rapids_code)),
      percentage(standards_with_work_processes_count),
      average_association_count("work_processes"),
      percentage(standards_with_related_instructions_count),
      average_association_count("related_instructions")
    ]
  end

  def total
    @total ||= scope.count
  end

  def ojt_type_counts
    @ojt_type_counts ||= scope.group(:ojt_type).count
  end

  def unknown_ojt_type_count
    total - ojt_type_counts.values.sum
  end

  def registration_agency_counts
    @registration_agency_counts ||= scope
      .joins(:registration_agency)
      .group("registration_agencies.agency_type")
      .count
  end

  def unknown_registration_agency_type_count
    total - registration_agency_counts.values.sum
  end

  def source_counts
    @source_counts ||= scope.group(:source).count
  end

  def unknown_source_count
    total - source_counts.values.sum
  end

  def present_count(column)
    scope.where.not(column => nil).count
  end

  def present_text_count(column)
    scope.where("NULLIF(TRIM(#{column}), '') IS NOT NULL").count
  end

  def standards_with_work_processes_count
    @standards_with_work_processes_count ||= scope.joins(:work_processes).distinct.count
  end

  def standards_with_related_instructions_count
    @standards_with_related_instructions_count ||= scope.joins(:related_instructions).distinct.count
  end

  def average_association_count(table_name)
    connection.select_value(<<~SQL.squish).to_f.round(2)
      SELECT COALESCE(AVG(item_count), 0)
      FROM (
        SELECT COUNT(*) AS item_count
        FROM #{table_name}
        WHERE occupation_standard_id IN (#{scope.select(:id).to_sql})
        GROUP BY occupation_standard_id
      ) association_counts
    SQL
  end

  def percentage(count)
    return 0 if total.zero?

    ((count.to_f / total) * 100).round(2)
  end

  def connection
    ActiveRecord::Base.connection
  end
end
