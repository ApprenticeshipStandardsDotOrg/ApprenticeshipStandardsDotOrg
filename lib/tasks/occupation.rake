require "csv"
require "roo"

namespace :occupation do
  task rapids_codes_scraper: :environment do
    if Date.current.wday.eql?(0) || ENV["FORCE"] == "true"
      puts "Importing RAPIDS codes"
      ScrapeRapidsCode.new.call
    else
      puts "Not Sunday, skipping"
      puts "Use FORCE=true to force this task"
    end
  end

  task onet_code_scraper: :environment do
    if Date.current.wday.eql?(0) || ENV["FORCE"] == "true"
      puts "Importing ONET codes"
      ScrapeOnetCodes.new.call
    else
      puts "Not Sunday, skipping"
      puts "Use FORCE=true to force this task"
    end
  end
end
