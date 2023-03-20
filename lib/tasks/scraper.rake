namespace :scraper do
  task states: :environment do
    if Date.current.wday.eql?(0) || ENV["FORCE"] == "true"
      puts "Running scraping jobs"
      Scraper::AppreticeshipBulletinsJob.perform_later
      Scraper::CaliforniaJob.perform_later
      Scraper::OregonJob.perform_later
      Scraper::NewYorkJob.perform_later
      Scraper::HcapJob.perform_later
    else
      puts "Not Sunday, skipping"
      puts "Use FORCE=true to force this task"
    end
  end
end
