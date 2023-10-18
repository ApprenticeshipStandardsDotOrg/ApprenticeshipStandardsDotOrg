namespace :after_party do
  desc 'Deployment task: import_2000_2006_2009_2010_onet_codes'
  task import_2000_2006_2009_2010_onet_codes: :environment do
    puts "Running deploy task 'import_2000_2006_2009_2010_onet_codes'"

    years = %w[2000 2006 2009 2010]

    years.each do |year|
      puts "Importing #{year}"
      filename = File.join(Rails.root, "lib", "tasks", "files", "#{year}_Occupations.csv")

      CSV.foreach(filename, headers: true) do |row|
        Onet.find_or_create_by!(
          version: year,
          code: row["O*NET-SOC #{year} Code"],
          title: row["O*NET-SOC #{year} Title"]
        )
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
