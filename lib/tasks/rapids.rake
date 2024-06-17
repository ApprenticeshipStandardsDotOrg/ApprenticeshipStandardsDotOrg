namespace :rapids do
  task import_data: :environment do
    if Date.current.wday.eql?(1) || ENV["FORCE"] == "true"
      puts "Running import data from RAPIDS job"
      ImportDataFromRAPIDSJob.perform_later
    else
      puts "Not Monday, skipping"
      puts "Use FORCE=true to force this task"
    end
  end
end
