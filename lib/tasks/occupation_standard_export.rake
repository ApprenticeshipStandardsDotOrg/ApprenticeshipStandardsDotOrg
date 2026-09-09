namespace :occupation_standards do
  desc "Export occupation standards for the configured SOC targets. Usage: bin/rails 'occupation_standards:export[tmp/occupation-standards.csv]'"
  task :export, [:path] => :environment do |_task, args|
    path = args[:path].presence || Rails.root.join("tmp", "occupation-standards-#{Time.zone.today}.csv")
    targets = OccupationStandardSocTargets.from_environment
    occupation_standards = targets.occupation_standards
    csv = OccupationStandardCsvExport.new(occupation_standards).to_csv

    if path.to_s == "-"
      print csv
    else
      File.write(path, csv)
      puts "SOC codes: #{targets.codes.join(", ")}"
      puts "Wrote #{occupation_standards.count} occupation standards to #{path}"
    end
  end

  desc "Enqueue AI conversions for source PDFs associated with the configured SOC targets"
  task enqueue_targeted_ai_conversions: :environment do
    targets = OccupationStandardSocTargets.from_environment
    pdfs = targets.source_pdfs_without_ai_conversion
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", false))

    puts "SOC codes: #{targets.codes.join(", ")}"
    puts "Matching occupation standards: #{targets.occupation_standards.count}"
    puts "Source PDFs: #{targets.source_pdfs.count}"
    puts "Source PDFs pending AI conversion: #{pdfs.count}"
    puts "Dry run: #{dry_run}"

    pdfs.find_each do |pdf|
      if dry_run
        puts "Would enqueue #{pdf.id}"
      else
        PdfReaderJob.perform_later(import_id: pdf.id, open_ai_prompt: OpenAIPrompt.default, force: false)
        puts "Enqueued #{pdf.id}"
      end
    end
  end
end
