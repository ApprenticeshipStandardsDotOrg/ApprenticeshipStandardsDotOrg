namespace :after_party do
  desc "Deployment task: import_2018_to_2019_onet_crosswalk"
  task import_2018_to_2019_onet_crosswalk: :environment do
    puts "Running deploy task 'import_2018_to_2019_onet_crosswalk'"

    filename = File.join(Rails.root, "lib", "tasks", "files", "2019_to_SOC_Crosswalk.csv")
    CSV.foreach(filename, headers: true) do |row|
      onet2019 = Onet.where(version: "2019", code: row["O*NET-SOC 2019 Code"]).sole
      onet2018 = Onet.where(version: "2018", code: row["2018 SOC Code"]).sole

      OnetMapping.create(onet: onet2018, next_version_onet: onet2019)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
