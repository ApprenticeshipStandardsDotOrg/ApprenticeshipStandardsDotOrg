namespace :source_file do
  task create_imports: :environment do
    count = 0
    SourceFile.missing_import.find_each do |source_file|
      import = source_file.create_import!

      if import
        count += 1

        if count % 500 == 0
          puts "Record count: #{count + 1}"
          sleep 10
        end
      end
    end
  end

  task transfer_data_to_import: :environment do
    Imports::Uncategorized.joins(:source_file).each do |import|
      import.transfer_source_file_data!
    end
  end
end
