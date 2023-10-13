namespace :after_party do
  desc 'Deployment task: import_2000_2006_2010_2019_onet_codes'
  task import_2000_2006_2010_2019_onet_codes: :environment do
    puts "Running deploy task 'import_2000_2006_2010_2019_onet_codes'"

    years = %w(2000 2006 2010 2019)

    years.each do |year|
      filename = File.join(Rails.root, "lib", "tasks", "files", "#{year}_Occupations.csv")

      CSV.foreach(filename, headers: true) do |row|
        Onet.find_or_create_by!(
          version: year,
          code: row["O*NET-SOC #{year} Code"],
          title: row["O*NET-SOC #{year} Title"]
        )
      end
    end
    # Put your task implementation HERE.

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
