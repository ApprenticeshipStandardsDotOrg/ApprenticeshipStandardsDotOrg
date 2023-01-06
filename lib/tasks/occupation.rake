require 'roo'

namespace :occupation do
  task rapids_codes_scraper: :environment do
    if Date.current.wday.eql?(0) || ENV["FORCE"] == "true"
      puts "Importing RAPIDS codes"
      xlsx = Roo::Spreadsheet.open('https://www.apprenticeship.gov/sites/default/files/wps/apprenticeship-occupations.xlsx')
      xlsx.sheet(0).parse(headers: true).each do |row|
        occupation = Occupation.find_or_initialize_by(name: row["RAPIDS TITLE"])
        occupation.update!(
          rapids_code: row["RAPIDS CODE"], 
          time_based_hours: row["TIME-BASED"], 
          hybrid_hours: row["HYBRID"], 
          competency_based_hours: row["COMPETENCY-BASED"] 
        )
      end
    else
      puts "Not Sunday, skipping"
      puts "Use FORCE=true to force this task"
    end
  end
end