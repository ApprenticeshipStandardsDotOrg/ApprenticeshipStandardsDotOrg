class ScrapeRAPIDSCode
  def call
    xlsx = Roo::Spreadsheet.open("https://www.apprenticeship.gov/sites/default/files/wps/apprenticeship-occupations.xlsx")
    xlsx.sheet(0).parse(headers: true).each_with_index do |row, index|
      next if index.zero?
      occupation = Occupation.find_or_initialize_by(title: row["RAPIDS TITLE"])
      onet = Onet.current_version.find_by(code: row["ONET SOC CODE"].strip)
      hybrid_hours_min = nil
      hybrid_hours_max = nil

      if row["HYBRID"]
        hours = row["HYBRID"]
        hybrid_hours = hours.to_s.match(/(?<hybrid_hours_min>\d{1,})\s*-\s*(?<hybrid_hours_max>\d{1,})/)

        if hybrid_hours
          hybrid_hours_min = hybrid_hours[:hybrid_hours_min]
          hybrid_hours_max = hybrid_hours[:hybrid_hours_max]
        else
          hybrid_hours_min = hours
          hybrid_hours_max = hours
        end
      end

      occupation.update!(
        rapids_code: row["RAPIDS CODE"],
        onet: onet,
        time_based_hours: row["TIME-BASED"],
        hybrid_hours_min: hybrid_hours_min,
        hybrid_hours_max: hybrid_hours_max,
        competency_based_hours: row["COMPETENCY-BASED"]
      )
    end
  end
end
