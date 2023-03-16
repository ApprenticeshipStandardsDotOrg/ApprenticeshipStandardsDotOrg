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
      file = URI.open("https://www.onetonline.org/find/all/All_Occupations.csv?fmt=csv")
      CSV.parse(file, headers: true) do |row|
        onet = Onet.find_or_initialize_by(name: row["Occupation"])
        onet.update!(code: row["Code"])
      end
    else
      puts "Not Sunday, skipping"
      puts "Use FORCE=true to force this task"
    end
  end
end
