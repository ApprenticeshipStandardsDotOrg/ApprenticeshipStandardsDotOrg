require "csv"

namespace :occupation do
  task onet_code_scraper: :environment do
    if Date.current.wday.eql? 0
      file = URI.open("https://www.onetonline.org/find/all/All_Occupations.csv?fmt=csv")
      CSV.parse(file, headers: true) do |row|
        occupation = Occupation.find_or_initialize_by(name: row["Occupation"])
        occupation.update!(onet_code: row["Code"])
      end
    end
  end
end