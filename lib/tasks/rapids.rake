namespace :rapids do
  task import_data: :environment do
    puts "Running import data from RAPIDS job"
    ImportDataFromRAPIDSJob.perform_later
  end
end
