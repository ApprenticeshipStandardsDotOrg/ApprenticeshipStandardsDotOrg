namespace :occupation_standards do
  desc "Export all occupation standards by SOC code. Usage: bin/rails 'occupation_standards:export[tmp/occupation-standards.csv]'"
  task :export, [:path] => :environment do |_task, args|
    path = args[:path].presence || Rails.root.join("tmp", "occupation-standards-#{Time.zone.today}.csv")
    csv = OccupationStandardCsvExport.new.to_csv

    if path.to_s == "-"
      print csv
    else
      File.write(path, csv)
      puts "Wrote #{OccupationStandard.count} occupation standards to #{path}"
    end
  end
end
