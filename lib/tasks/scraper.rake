namespace :scraper do
  task states: :environment do
    if Date.current.wday.eql?(0) || ENV["FORCE"] == "true"
      puts "Running scraping jobs"
      Scraper::CaliforniaJob.perform_later
      Scraper::OregonJob.perform_later
      Scraper::AppreticeshipBulletinsJob.perform_later
    else
      puts "Not Sunday, skipping"
      puts "Use FORCE=true to force this task"
    end
  end
end
