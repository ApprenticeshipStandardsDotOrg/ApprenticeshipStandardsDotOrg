require "csv"
require "roo"

namespace :occupation do
  task rapids_codes_scraper: :environment do
    if Date.current.wday.eql?(0) || ENV["FORCE"] == "true"
      puts "Importing RAPIDS codes"
      xlsx = Roo::Spreadsheet.open("https://www.apprenticeship.gov/sites/default/files/wps/apprenticeship-occupations.xlsx")
      xlsx.sheet(0).parse(headers: true).each_with_index do |row, index|
        next if index.zero?
        occupation = Occupation.find_or_initialize_by(name: row["RAPIDS TITLE"])
        onet_code = OnetCode.find_by(code: row["ONET SOC CODE"].strip)
        hybrid_start_hours = nil
        hybrid_end_hours = nil
        hybrid_hours = nil

        if row["HYBRID"]
          hours = row["HYBRID"]
          hybrid_start_hours = hours.match(/(\d{1,})\s*-/)
          hybrid_end_hours = hours.match(/-\s*(\d{1,})/)

          hybrid_hours = if hybrid_start_hours && hybrid_end_hours
            (hybrid_start_hours[1]..hybrid_end_hours[1])
          else
            (hours..hours)
          end
        end

        occupation.update!(
          rapids_code: row["RAPIDS CODE"],
          onet_code: onet_code,
          time_based_hours: row["TIME-BASED"],
          hybrid_hours: hybrid_hours,
          competency_based_hours: row["COMPETENCY-BASED"]
        )
      end
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
        onet_code = OnetCode.find_or_initialize_by(name: row["Occupation"])
        onet_code.update!(code: row["Code"])
      end
    else
      puts "Not Sunday, skipping"
      puts "Use FORCE=true to force this task"
    end
  end
end
