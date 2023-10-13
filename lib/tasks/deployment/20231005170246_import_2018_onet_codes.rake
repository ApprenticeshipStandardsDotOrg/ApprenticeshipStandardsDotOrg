namespace :after_party do
  desc "Deployment task: import_2018_onet_codes"
  task import_2018_onet_codes: :environment do
    puts "Running deploy task 'import_2018_onet_codes'"

    filename = File.join(Rails.root, "lib", "tasks", "files", "2019_to_SOC_Crosswalk.csv")
    CSV.foreach(filename, headers: true) do |row|
      Onet.find_or_create_by!(
        version: "2018",
        code: row["2018 SOC Code"],
        title: row["2018 SOC Title"]
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
