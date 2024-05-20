namespace :import do
  task process_unfurled: :environment do
    [
      Imports::Doc,
      Imports::Docx,
      Imports::DocxListing,
      Imports::Uncategorized
    ].each do |model|
      puts "Processing unfurled #{model} records"
      model.unfurled.find_each.with_index do |import, index|
        import.process
        rest(index)
      end

      sleep 60
    end
  end

  def rest(index)
    if (index+1) % 200 == 0
      puts "Record count: #{index+1}"
      sleep 10
    end
  end
end
