require "csv"

namespace :occupation_standards do
  desc "Audit OJT approaches against source evidence without AI calls or database changes. Usage: bin/rails 'occupation_standards:ojt_audit[input.csv,tmp/ojt-audit.csv]'"
  task :ojt_audit, [:input, :output] => :environment do |_task, args|
    raise ArgumentError, "Provide the fixed benchmark CSV and output path" unless args[:input].present? && args[:output].present?
    if File.expand_path(args[:input]) == File.expand_path(args[:output]) || (File.exist?(args[:output]) && File.identical?(args[:input], args[:output]))
      raise ArgumentError, "Output must not overwrite the benchmark input"
    end

    ids = CSV.read(args[:input], headers: true).map { |row| row.fetch("id").to_s.split("/").last }.uniq
    unless ids.all? { |id| id.match?(/\A[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}\z/i) }
      raise ArgumentError, "Input id column must contain standard UUIDs or admin URLs"
    end
    scope = OccupationStandard.where(id: ids)
    raise ArgumentError, "Some benchmark standards are missing from this database" unless scope.count == ids.size

    csv = OccupationStandardOJTAuditReport.new(scope, filters: "fixed CSV IDs").to_csv
    File.write(args[:output], csv)
    puts "Wrote #{ids.size} OJT audits to #{args[:output]}; no AI calls or database changes"
  end
end
