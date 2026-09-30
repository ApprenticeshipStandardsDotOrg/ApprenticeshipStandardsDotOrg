namespace :nofs do
  desc "Create missing NOF bulletin imports and enqueue their PDFs for AI conversion"
  task populate: :environment do
    nofs_source = ENV.fetch(
      "NOFS_CSV",
      Rails.root.join("lib/tasks/files/nofs.csv").to_s
    )
    bulletins_source = ENV.fetch(
      "BULLETINS_CSV",
      Scraper::ApprenticeshipBulletinsJob::BULLETIN_LIST_URL
    )
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", false))

    result = PopulateNofOccupationStandards.call(
      nofs_source:,
      bulletins_source:,
      dry_run:
    )

    puts "NOF population #{dry_run ? "dry run" : "run"}:"
    result.entries.group_by { |entry| entry.fetch("Status") }.sort.each do |status, entries|
      puts "  #{status}: #{entries.length}"
    end

    result.entries.reject { |entry| entry["Status"].in?(["already_populated", "enqueued"]) }.each do |entry|
      puts "  #{entry["Occupation"]}: #{entry["Status"]} - #{entry["Summary"]}"
    end

    if ENV["REPORT_PATH"].present?
      headers = result.entries.flat_map(&:keys).uniq
      CSV.open(ENV["REPORT_PATH"], "w", headers:, write_headers: true) do |csv|
        result.entries.each { |entry| csv << headers.map { |header| entry[header] } }
      end
      puts "Wrote report to #{ENV["REPORT_PATH"]}"
    end
  end
end
