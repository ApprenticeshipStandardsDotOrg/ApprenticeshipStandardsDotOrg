namespace :scraper do
  task states: :environment do
    if Date.current.wday.eql?(0) || ENV["FORCE"] == "true"
      puts "Running scraping jobs"
      Scraper::ApprenticeshipBulletinsJob.perform_later
      Scraper::CaliforniaJob.perform_later
      Scraper::OregonJob.perform_later
      Scraper::NewYorkJob.perform_later
      Scraper::HcapJob.perform_later
      Scraper::WashingtonJob.perform_later
    else
      puts "Not Sunday, skipping"
      puts "Use FORCE=true to force this task"
    end
  end

  desc "one-off task to convert any remaining doc files to pdf"
  task doc_to_pdf: :environment do
    StandardsImport.find_each do |standard_import|
      standard_import.source_files.each do |source_file|
        DocToPdfConverterJob.perform_later(source_file)
      end
    end
  end
end
