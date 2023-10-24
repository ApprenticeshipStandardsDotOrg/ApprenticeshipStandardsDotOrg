namespace :after_party do
  desc "Deployment task: import_2009_to_2010_onet_crosswalk"
  task import_2009_to_2010_onet_crosswalk: :environment do
    puts "Running deploy task 'import_2009_to_2010_onet_crosswalk'"

    filename = File.join(Rails.root, "lib", "tasks", "files", "2009_to_2010_Crosswalk.csv")
    CSV.foreach(filename, headers: true) do |row|
      onet2010 = Onet.where(version: "2010", code: row["O*NET-SOC 2010 Code"]).sole
      onet2009 = Onet.where(version: "2009", code: row["O*NET-SOC 2009 Code"]).sole

      OnetMapping.create(onet: onet2009, next_version_onet: onet2010)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
