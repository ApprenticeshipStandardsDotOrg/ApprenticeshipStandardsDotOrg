namespace :text_representation do
  task import_missing: :environment do
    DataImport.all.find_each do |di|
      puts di.id
      next unless di.import
      begin
        di.to_text
      rescue PDF::Reader::MalformedPDFError
        next
      end
    end
  end
end
