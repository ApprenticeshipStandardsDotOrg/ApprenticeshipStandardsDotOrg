namespace :import do
  task process_unfurled: :environment do
    [
      Imports::Doc,
      Imports::Docx,
      Imports::DocxListing,
      Imports::Uncategorized
    ].each do |model|
      puts "Processing unfurled #{model} records"
      model.needs_unfurling.find_each.with_index do |import, index|
        import.process
        rest(index)
      rescue
      end
    end
  end

  def rest(index)
    if (index + 1) % 500 == 0
      puts "Record count: #{index + 1}"
      sleep 15
    end
  end
end
