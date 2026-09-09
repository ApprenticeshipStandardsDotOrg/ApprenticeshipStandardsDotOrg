require "csv"

class OccupationStandardCsvExport
  HEADERS = %w[
    soc_code
    rapids_code
    onet_code
    org_name
    state_name
    source
    name
    occupation_standard_url
    num_processes
    num_competencies
    ai_converted
  ].freeze

  PROD_BASE_URL = "https://apprenticeshipstandards.org/occupation_standards".freeze

  def initialize(relation = OccupationStandard.all)
    @relation = relation
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << HEADERS
      occupation_standards.each { |occupation_standard| csv << row(occupation_standard) }
    end
  end

  private

  attr_reader :relation

  def occupation_standards
    relation
      .includes(:organization, registration_agency: :state)
      .select(<<~SQL.squish)
        occupation_standards.*,
        (SELECT COUNT(*)
          FROM work_processes
          WHERE work_processes.occupation_standard_id = occupation_standards.id
        ) AS export_num_processes,
        (SELECT COUNT(*)
          FROM competencies
          INNER JOIN work_processes
            ON work_processes.id = competencies.work_process_id
          WHERE work_processes.occupation_standard_id = occupation_standards.id
        ) AS export_num_competencies
      SQL
      .order(Arel.sql(<<~SQL.squish))
        REGEXP_REPLACE(NULLIF(occupation_standards.onet_code, ''), '\\.[0-9]+$', '') ASC NULLS LAST,
        occupation_standards.onet_code ASC NULLS LAST,
        occupation_standards.id ASC
      SQL
  end

  def row(occupation_standard)
    [
      soc_code(occupation_standard.onet_code),
      occupation_standard.rapids_code,
      occupation_standard.onet_code,
      occupation_standard.organization&.title,
      occupation_standard.registration_agency&.state&.name,
      occupation_standard.source,
      occupation_standard.title,
      "#{PROD_BASE_URL}/#{occupation_standard.id}",
      occupation_standard.export_num_processes,
      occupation_standard.export_num_competencies,
      occupation_standard.source_ai_conversion? ? 1 : 0
    ]
  end

  def soc_code(onet_code)
    onet_code.to_s.sub(/\.[0-9]+\z/, "").presence
  end
end
