namespace :data_import do
  task daily_report: :environment do
    AdminMailer.daily_uploads_report.deliver_now
  end

  desc "One-off task to link existing data_imports to new import field"
  task link_to_import: :environment do
    DataImport.where(import_id: nil).find_each do |data_import|
      data_import.set_import_field!
    end
  end
end
