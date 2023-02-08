namespace :scraper do
  task states: :environment do
    if Date.current.wday.eql?(0) || ENV["FORCE"] == "true"
      Scraper::CaliforniaJob.perform_later
    end
  end
end
