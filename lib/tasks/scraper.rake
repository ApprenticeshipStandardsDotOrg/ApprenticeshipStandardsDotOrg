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

  desc "one-off task to extract attachments from bulletins"
  task back_extract_bulletins: :environment do
    # Checking for bulletin: false since we want to back extract Bulletins
    # that existed before we added that flag.
    StandardsImport.where(bulletin: false).where("notes LIKE ?", "%BulletinsJob%").find_each do |standards_import|
      standards_import.source_files.each do |source_file|
        begin
          if source_file.docx?
            Scraper::ExportFileAttachmentsJob.perform_now(source_file)
          end
          standards_import.update!(bulletin: true)
        rescue => e
          Rails.error.report(e)
        end
      end
    end
  end
end
